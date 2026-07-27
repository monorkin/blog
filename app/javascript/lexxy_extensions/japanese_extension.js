import { Extension, Lexical } from "lexxy"
import { KANA_RUN_PATTERN, lengthenReading, romajiToKana, tokenizeKana } from "lexxy_extensions/kana"

const {
  $applyNodeReplacement,
  $createRangeSelection,
  $getSelection,
  $isRangeSelection,
  $setSelection,
  COMMAND_PRIORITY_LOW,
  SELECTION_CHANGE_COMMAND,
  TextNode
} = Lexical

const TYPED_ROMAJI_PATTERN = /^[a-zA-Z'!?,.-]+$/

// Japanese writing support:
//
// - A toolbar toggle (あ) switches the editor into kana input mode, where romaji
//   typed on a latin keyboard is converted into kana as you type: "ko" → こ,
//   "KO" → コ, "kk" → っ + pending "k".
// - Any kana in the document — typed, pasted, or loaded — is annotated with its
//   romaji reading using <ruby> elements, one per syllable.
//
// Typed romaji is detected inside a TextNode transform rather than by
// intercepting insertion commands: Lexical inserts typed characters through
// several paths (commands, DOM reconciliation) and only the transform sees them
// all. The transform diffs the text before the caret against a snapshot taken
// after the previous change; whatever was appended since is what the user just
// typed, and gets accumulated into a pending romaji buffer until it forms
// complete syllables. Moving the caret invalidates the snapshot and resets the
// buffer.
export default class JapaneseExtension extends Extension {
  #kanaMode = false
  #pendingRomaji = ""
  #snapshotBeforeCaret = ""
  #toolbarButton = null

  get enabled() {
    return this.editorElement.supportsRichText
  }

  get lexicalExtension() {
    return this.defineExtension({
      name: "blog/japanese",
      nodes: [ RubyNode ],
      register: (editor) => this.#registerListeners(editor)
    })
  }

  get allowedElements() {
    return [ "ruby", "rt", "rp" ]
  }

  initializeToolbar(toolbar) {
    this.#toolbarButton = this.#createToolbarButton()
    toolbar.appendChild(this.#toolbarButton)
  }

  dispose() {
    this.#kanaMode = false
    this.#resetTypingSession()
    this.#toolbarButton = null
  }

  // Private

  #registerListeners(editor) {
    const unregisterTransform = editor.registerNodeTransform(TextNode, (textNode) => this.#transformTextNode(textNode))
    const unregisterSelectionChange = editor.registerCommand(SELECTION_CHANGE_COMMAND, () => this.#trackCaret(), COMMAND_PRIORITY_LOW)

    return () => {
      unregisterTransform()
      unregisterSelectionChange()
    }
  }

  #createToolbarButton() {
    const button = document.createElement("button")
    button.type = "button"
    button.name = "kana"
    button.className = "lexxy-editor__toolbar-button"
    button.title = "Japanese kana input"
    button.setAttribute("aria-pressed", "false")
    button.textContent = "あ"
    button.addEventListener("click", () => this.#toggleKanaMode())
    return button
  }

  #toggleKanaMode() {
    this.#kanaMode = !this.#kanaMode
    this.#resetTypingSession()
    this.#toolbarButton?.setAttribute("aria-pressed", this.#kanaMode.toString())
    this.editorElement.editor.focus()
  }

  // Caret movements that don't come from typing (clicks, arrow keys) start a
  // new typing session at the new location.
  #trackCaret() {
    const textBeforeCaret = this.#currentTextBeforeCaret()

    if (textBeforeCaret !== this.#snapshotBeforeCaret) {
      this.#snapshotBeforeCaret = textBeforeCaret
      this.#pendingRomaji = ""
    }

    return false
  }

  #transformTextNode(textNode) {
    if (!textNode.isSimpleText() || textNode.isComposing()) return

    if (this.#kanaMode) this.#convertTypedRomaji(textNode)
    if (textNode.isAttached()) this.#annotateKana(textNode)
  }

  #convertTypedRomaji(textNode) {
    const anchor = this.#collapsedAnchorIn(textNode)
    if (!anchor) return

    const textBeforeCaret = textNode.getTextContent().slice(0, anchor.offset)
    if (textBeforeCaret === this.#snapshotBeforeCaret) return

    const typed = this.#typedSince(textBeforeCaret)
    if (typed === null) {
      this.#endTypingSession(textNode, textBeforeCaret)
      return
    }

    const romaji = this.#pendingRomaji + typed
    const { converted, pending } = romajiToKana(romaji)
    const display = converted + pending

    if (display !== romaji) {
      textNode.spliceText(anchor.offset - romaji.length, romaji.length, display, true)
    }

    this.#pendingRomaji = pending
    this.#snapshotBeforeCaret = this.#currentTextBeforeCaret()
  }

  #typedSince(textBeforeCaret) {
    if (!textBeforeCaret.startsWith(this.#snapshotBeforeCaret)) return null

    const typed = textBeforeCaret.slice(this.#snapshotBeforeCaret.length)
    return TYPED_ROMAJI_PATTERN.test(typed) ? typed : null
  }

  // When the typing session is interrupted by non-romaji input, a lone pending
  // "n" is a complete syllable: commit it as ん before starting over.
  #endTypingSession(textNode, textBeforeCaret) {
    const flushableN = (this.#pendingRomaji === "n" || this.#pendingRomaji === "N") &&
      textBeforeCaret.startsWith(this.#snapshotBeforeCaret)

    if (flushableN) {
      textNode.spliceText(this.#snapshotBeforeCaret.length - 1, 1, this.#pendingRomaji === "n" ? "ん" : "ン", false)
    }

    this.#pendingRomaji = ""
    this.#snapshotBeforeCaret = this.#currentTextBeforeCaret()
  }

  #resetTypingSession() {
    this.#pendingRomaji = ""
    this.#snapshotBeforeCaret = ""
  }

  #annotateKana(textNode) {
    if (this.#mergeLengthenerIntoPreviousRuby(textNode)) return

    const text = textNode.getTextContent()
    const match = KANA_RUN_PATTERN.exec(text)
    if (!match) return

    const run = this.#withoutTrailingSokuonAtCaret(textNode, match[0], match.index)
    if (run === "") return

    const target = $isolateRun(textNode, match.index, match.index + run.length)
    const caretWasInTarget = $isCollapsedIn(target)

    let previous = target
    for (const token of tokenizeKana(run)) {
      const rubyNode = $createRubyNode(token.text, token.reading)
      previous.insertAfter(rubyNode)
      previous = rubyNode
    }
    target.remove()

    if (caretWasInTarget) {
      $selectAfter(previous)
      this.#snapshotBeforeCaret = this.#currentTextBeforeCaret()
    }
  }

  // A ー typed right after an annotated syllable lengthens that syllable —
  // コ then ー should read "kō", not "ko" followed by "-" — so fold it into the
  // preceding ruby node instead of annotating it on its own.
  #mergeLengthenerIntoPreviousRuby(textNode) {
    const lengtheners = textNode.getTextContent().match(/^ー+/)
    if (!lengtheners) return false

    const previous = textNode.getPreviousSibling()
    if (!$isRubyNode(previous)) return false

    let reading = previous.getReading()
    for (const _ of lengtheners[0]) reading = lengthenReading(reading)

    const merged = $createRubyNode(previous.getTextContent() + lengtheners[0], reading)
    previous.replace(merged)

    const caretWasInNode = Boolean(this.#collapsedAnchorIn(textNode))
    textNode.spliceText(0, lengtheners[0].length, "", false)
    if (textNode.getTextContentSize() === 0) textNode.remove()

    if (caretWasInNode) {
      if (!textNode.isAttached()) $selectAfter(merged)
      this.#snapshotBeforeCaret = this.#currentTextBeforeCaret()
    }

    return true
  }

  // A っ at the end of the run right before the caret is still being typed —
  // it geminates the next syllable ("kko" → っこ, read "kko") — so leave it
  // unannotated until that syllable arrives.
  #withoutTrailingSokuonAtCaret(textNode, run, runStart) {
    if (!this.#kanaMode) return run

    const anchor = this.#collapsedAnchorIn(textNode)
    if (!anchor) return run
    if (anchor.offset !== runStart + run.length + this.#pendingRomaji.length) return run

    return run.replace(/[っッ]+$/, "")
  }

  #collapsedAnchorIn(textNode) {
    const selection = $getSelection()
    if (!$isRangeSelection(selection) || !selection.isCollapsed()) return null

    const anchor = selection.anchor
    if (anchor.type !== "text" || anchor.key !== textNode.getKey()) return null

    return anchor
  }

  #currentTextBeforeCaret() {
    const selection = $getSelection()
    if (!$isRangeSelection(selection) || !selection.isCollapsed()) return ""

    const anchor = selection.anchor
    if (anchor.type !== "text") return ""

    const anchorNode = anchor.getNode()
    if (!anchorNode.isSimpleText()) return ""

    return anchorNode.getTextContent().slice(0, anchor.offset)
  }
}

// An atomic base + reading pair rendered as <ruby>か<rt>ka</rt></ruby>, both in
// the editor and in the exported Action Text HTML. A token-mode TextNode rather
// than a decorator: the caret moves through it like regular text, but deletion
// removes the whole syllable at once.
class RubyNode extends TextNode {
  static getType() {
    return "ruby"
  }

  static clone(node) {
    return new RubyNode(node.__text, node.__reading, node.__key)
  }

  static importJSON(serializedNode) {
    return $createRubyNode(serializedNode.text, serializedNode.reading).updateFromJSON(serializedNode)
  }

  static importDOM() {
    return {
      ruby: () => ({ conversion: $convertRubyElement, priority: 1 })
    }
  }

  constructor(text, reading, key) {
    super(text, key)
    this.__reading = reading
  }

  getReading() {
    return this.getLatest().__reading
  }

  createDOM() {
    return this.#createRubyElement()
  }

  updateDOM(prevNode, dom, config) {
    return prevNode.__reading !== this.__reading || super.updateDOM(prevNode, dom, config)
  }

  exportDOM() {
    return { element: this.#createRubyElement() }
  }

  exportJSON() {
    return { ...super.exportJSON(), type: "ruby", reading: this.__reading, version: 1 }
  }

  canHaveFormat() {
    return false
  }

  #createRubyElement() {
    const ruby = document.createElement("ruby")
    ruby.appendChild(document.createTextNode(this.__text))

    const rt = document.createElement("rt")
    rt.textContent = this.__reading
    ruby.appendChild(rt)

    return ruby
  }
}

function $createRubyNode(base, reading) {
  return $applyNodeReplacement(new RubyNode(base, reading).setMode("token"))
}

function $isRubyNode(node) {
  return node instanceof RubyNode
}

function $convertRubyElement(element) {
  const base = element.cloneNode(true)
  base.querySelectorAll("rt, rp").forEach(annotation => annotation.remove())

  if (base.textContent === "") {
    return { node: null }
  } else {
    const reading = element.querySelector("rt")?.textContent ?? ""
    return { node: $createRubyNode(base.textContent, reading), after: () => [] }
  }
}

function $isolateRun(textNode, start, end) {
  let target = textNode

  if (start > 0) {
    [ , target ] = textNode.splitText(start)
  }
  if (end - start < target.getTextContentSize()) {
    [ target ] = target.splitText(end - start)
  }

  return target
}

function $isCollapsedIn(node) {
  const selection = $getSelection()
  return $isRangeSelection(selection) && selection.isCollapsed() && selection.anchor.key === node.getKey()
}

function $selectAfter(node) {
  const parent = node.getParentOrThrow()
  const offset = node.getIndexWithinParent() + 1

  const selection = $createRangeSelection()
  selection.anchor.set(parent.getKey(), offset, "element")
  selection.focus.set(parent.getKey(), offset, "element")
  $setSelection(selection)
}
