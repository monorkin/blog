import { parse, type HTMLElement, type Node } from "node-html-parser"

// A port of Action Text's PlainTextConversion, so excerpts, descriptions and
// reading times match what the Rails app produced. Figures stand in for Action
// Text attachments, whose "[caption]" representation the Rails app stripped.

const BLOCKS = [ "h1", "h2", "h3", "h4", "h5", "h6", "p" ]
const SKIPPED = [ "script", "style", "rt", "rp" ]
const INLINE_PARENTS = [ "p", "h1", "h2", "h3", "h4", "h5", "h6", "li", "td", "th", "a", "strong", "em", "b", "i", "code", "del", "span" ]

export function plainText(html: string) {
  const root = parse(html, { blockTextElements: { script: true, style: true } })

  return removeTrailingNewlines(textFor(root))
    .replace(/\[[^\]]*\]/g, "")
}

function textFor(node: Node): string {
  if (node.nodeType === 3) {
    return textForTextNode(node)
  } else if (node.nodeType === 1) {
    return textForElement(node as HTMLElement)
  } else {
    return ""
  }
}

// Newlines inside a paragraph are Markdown's soft line breaks, which read as spaces. Rails'
// content had none; between blocks, newlines are just markup and count for nothing.
function textForTextNode(node: Node) {
  let text = node.text

  if (isInsidePre(node)) {
    return text
  } else if (isInline(node)) {
    return text.replace(/\n/g, " ")
  } else {
    if (previousElementName(node) === "br") {
      text = text.replace(/^\n/, "")
    }

    return removeTrailingNewlines(text)
  }
}

function isInline(node: Node) {
  return INLINE_PARENTS.includes(tagName(node.parentNode as HTMLElement))
}

function textForElement(element: HTMLElement): string {
  const name = element.rawTagName?.toLowerCase() ?? ""
  const childText = () => element.childNodes.map(textFor).join("")

  if (SKIPPED.includes(name) || isAttachment(element)) {
    return ""
  } else if (BLOCKS.includes(name)) {
    return block(childText())
  } else if (name === "ul" || name === "ol") {
    return breakIfNestedList(element, block(childText()))
  } else if (name === "br") {
    return "\n"
  } else if (name === "div") {
    return `${removeTrailingNewlines(childText())}\n`
  } else if (name === "blockquote") {
    return quote(block(childText()))
  } else if (name === "li") {
    return listItem(element, childText())
  } else {
    return childText()
  }
}

function isAttachment(element: HTMLElement) {
  return element.classList.contains("attachment") || element.classList.contains("attachment-gallery")
}

function block(text: string) {
  return `${removeTrailingNewlines(text)}\n\n`
}

function quote(text: string) {
  if (text.trim() === "") {
    return "“”"
  } else {
    const first = text.search(/\S/)
    const last = text.length - text.split("").reverse().join("").search(/\S/)

    return `${text.slice(0, first)}“${text.slice(first, last)}”${text.slice(last)}`
  }
}

function listItem(element: HTMLElement, text: string) {
  const depth = listDepth(element)
  const indentation = "  ".repeat(Math.max(depth - 1, 0))

  return `${indentation}${bulletFor(element)} ${removeTrailingNewlines(text)}\n`
}

function bulletFor(element: HTMLElement) {
  const list = ancestors(element).find(ancestor => [ "ul", "ol" ].includes(tagName(ancestor)))

  if (list && tagName(list) === "ol") {
    const siblings = (element.parentNode as HTMLElement).childNodes.filter(node => node.nodeType === 1)
    return `${siblings.indexOf(element) + 1}.`
  } else {
    return "•"
  }
}

function breakIfNestedList(element: HTMLElement, text: string) {
  if (listDepth(element) > 0) {
    return `\n${text}`
  } else {
    return text
  }
}

function listDepth(element: HTMLElement) {
  return ancestors(element).filter(ancestor => [ "ul", "ol" ].includes(tagName(ancestor))).length
}

function ancestors(node: Node) {
  const result: HTMLElement[] = []
  let current = node.parentNode

  while (current) {
    result.push(current)
    current = current.parentNode
  }

  return result
}

function isInsidePre(node: Node) {
  return ancestors(node).some(ancestor => tagName(ancestor) === "pre")
}

function previousElementName(node: Node) {
  const siblings = node.parentNode!.childNodes
  const previous = siblings[siblings.indexOf(node) - 1]

  if (previous && previous.nodeType === 1) {
    return tagName(previous as HTMLElement)
  }
}

function tagName(element: HTMLElement) {
  return element.rawTagName?.toLowerCase() ?? ""
}

function removeTrailingNewlines(text: string) {
  return text.replace(/(\r?\n)+$/, "")
}
