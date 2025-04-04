import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static targets = [ "editor", "codeBlockLanguagePickerDialog", "codeBlockLanguagePickerSelect" ]
  static classes = [ "loading", "ready" ]
  static values = {
    supportedCodeBlockLanguages: Object
  }

  async initialize() {
    await import("initializers/rich_text")
  }

  connect() {
    this.element.classList.remove(this.readyClass)
    this.element.classList.add(this.loadingClass)
  }

  editorReady() {
    if (this.hasSupportedCodeBlockLanguagesValue) this.#initCodeBlockLanguageSelector()

    this.element.classList.add(this.readyClass)
    this.element.classList.remove(this.loadingClass)
  }

  attributeChanged(event) {
    this.#toggleCodeBlockLanguagePickerDialog()
  }

  selectionChanged(event) {
    this.#toggleCodeBlockLanguagePickerDialog()
  }

  repositionDialogs(event) {
    if (this.codeBlockLanguagePickerDialogShown) {
      this.#positionCodeBlockLanguagePickerDialog(this.#selectedCodeBlock)
    }
  }

  pickCodeBlockLanguage(event) {
    if (!this.#codeBlockAtStoredPosition) return

    const target = event.target

    this.#applyDialogChanges(
      this.codeBlockLanguagePickerDialogTarget,
      `Set code block language to ${target.value}`,
      async () => {
        await new Promise(requestAnimationFrame)
        this.#editor.setHTMLAtributeAtPosition(this.editorPosition, "language", target.value)
        this.#editor.setSelectedRange(this.editorPosition)
        this.#toggleCodeBlockLanguagePickerDialog()
      }
    )
  }

  get #editor() {
    return this.editorTarget.editor
  }

  get #document() {
    return this.#editor.getDocument()
  }

  #applyDialogChanges(dialog, message, callback) {
    this.#editor.recordUndoEntry(message)
    callback()
    this.#closeDialog(dialog)
  }

  get #trixToolbarElement() {
    const toolbarId = this.editorTarget.attributes.getNamedItem("toolbar")?.value
    if (!toolbarId) return

    return document.querySelector(`#${toolbarId}`)
  }

  #initCodeBlockLanguageSelector() {
    const trixDialogs = this.#trixToolbarElement.querySelector("[data-trix-dialogs]")
    trixDialogs.insertAdjacentHTML("beforeend", this.#codeBlockLanguagePickerDialog())
  }

  #codeBlockLanguagePickerDialog() {
    return `
    <div class="trix-dialog trix-dialog--language" data-trix-dialog="language-picker" data-rich-text-target="codeBlockLanguagePickerDialog">
      <div class="language-picker">
        <select class="language-picker__select" data-rich-text-target="codeBlockLanguagePickerSelect" data-action="change->rich-text#pickCodeBlockLanguage">
          ${this.#codeBlockLanguageOptions()}
        </select>
      </div>
    </div>
    `
  }

  #codeBlockLanguageOptions() {
    return Object.entries(this.supportedCodeBlockLanguagesValue).map(([tag, name]) => {
      return `<option value="${tag}">${name}</option>`
    }).join("\n")
  }

  #toggleCodeBlockLanguagePickerDialog() {
    if (!this.hasCodeBlockLanguagePickerDialogTarget) return

    this.editorPosition = this.#editor.getPosition()
    const codeBlock = this.#selectedCodeBlock

    if (codeBlock) {
      this.#showCodeBlockLanguagePickerDialog(codeBlock)
    } else {
      this.#hideCodeBlockLanguagePickerDialog()
    }
  }

  get #selectedCodeBlock() {
    return this.#focusedElement?.closest("pre")
  }

  get #focusedElement() {
    let focusNode = window.getSelection().focusNode

    if (focusNode?.nodeType === Node.TEXT_NODE) {
      focusNode = focusNode.parentElement
    }

    return focusNode
  }

  get #codeBlockAtStoredPosition() {
    return this.#document.getBlockAtPosition(this.editorPosition)
  }

  #showCodeBlockLanguagePickerDialog(codeBlock) {
    const language = this.#codeBlockLanguage || "text"
    this.codeBlockLanguagePickerSelectTarget.value = language
    this.codeBlockLanguagePickerDialogTarget.setAttribute("data-trix-active", "true")
    this.#positionCodeBlockLanguagePickerDialog(codeBlock)
  }

  #closeDialog(dialog) {
    dialog.removeAttribute("data-trix-active")
  }

  get #codeBlockLanguage() {
    const codeBlock = this.#selectedCodeBlock
    return codeBlock.getAttribute("language")
  }

  #positionCodeBlockLanguagePickerDialog(codeBlock) {
    const editorRect = this.editorTarget.getBoundingClientRect()
    const codeBlockRect = codeBlock.getBoundingClientRect()
    const dialogRect = this.codeBlockLanguagePickerDialogTarget.getBoundingClientRect()

    this.codeBlockLanguagePickerDialogTarget.style.left = `${codeBlockRect.left - editorRect.left + codeBlockRect.width - dialogRect.width}px`
    this.codeBlockLanguagePickerDialogTarget.style.top = `${codeBlockRect.top - dialogRect.height * 1.5}px`
  }

  #hideCodeBlockLanguagePickerDialog() {
    this.codeBlockLanguagePickerDialogTarget.removeAttribute("data-trix-active")
  }

  get codeBlockLanguagePickerDialogShown() {
    return this.hasCodeBlockLanguagePickerDialogTarget && 
      this.codeBlockLanguagePickerDialogTarget.hasAttribute("data-trix-active")
  }
}
