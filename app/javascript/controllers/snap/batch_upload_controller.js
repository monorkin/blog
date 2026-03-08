import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static targets = ["dropZone", "fileInput", "rows", "template", "row", "singleForm", "batchForm"]

  // Actions

  addFiles({ target }) {
    this.#processFiles(target.files)
    target.value = ""
  }

  dragover(event) {
    event.preventDefault()
  }

  dragenter(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.add("batch-upload__drop-zone--active")
  }

  dragleave() {
    this.dropZoneTarget.classList.remove("batch-upload__drop-zone--active")
  }

  drop(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove("batch-upload__drop-zone--active")
    this.#processFiles(event.dataTransfer.files)
  }

  removeRow({ currentTarget }) {
    currentTarget.closest("[data-snap--batch-upload-target='row']").remove()
    this.#toggleForms()
  }

  // Private

  #processFiles(files) {
    Array.from(files).forEach(file => this.#addRow(file))
    this.#toggleForms()
  }

  #addRow(file) {
    const row = this.templateTarget.content.firstElementChild.cloneNode(true)

    row.querySelector("[name='snaps[][title]']").value = this.#titleFromFilename(file.name)

    const preview = row.querySelector("[data-preview]")
    if (file.type.startsWith("image/")) {
      preview.src = URL.createObjectURL(file)
    } else {
      preview.hidden = true
    }

    const fileInput = row.querySelector("[data-file-input]")
    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    fileInput.files = dataTransfer.files

    this.rowsTarget.appendChild(row)
  }

  #toggleForms() {
    const hasBatchRows = this.rowTargets.length > 0
    this.singleFormTarget.classList.toggle("hidden", hasBatchRows)
    this.batchFormTarget.classList.toggle("hidden", !hasBatchRows)
  }

  #titleFromFilename(filename) {
    return filename
      .replace(/\.[^.]+$/, "")
      .replace(/[_-]/g, " ")
      .replace(/\b\w/g, c => c.toUpperCase())
  }
}
