import ApplicationController from "controllers/application_controller"
import Dialog from "models/dialog"

// This controller is used to implement links that open up within a mocal
// window. It works by observing when the link is clicked, and creating a modal
// with a turbo frame, and setting the URL of the turbo frame to the URL of the
// link.
// For this to you have to define the name of the frame that the server will
// render on the URL the link points to, and you have to render a frame with the
// same name on that  page.
export default class extends ApplicationController {
  static values = {
    frameName: String,
    class: String,
    dataAttributes: Object
  }

  // Lifecycle

  connect() {
    if (!this.hasFrameNameValue) {
      throw new Error("You must specify a frame name with data-modal-action-frame-name-value")
    }
  }

  disconnect() {
    this.#dialog?.close()
  }

  // Actions

  openModal(event) {
    event.preventDefault()

    this.#dialog = Dialog.create({ removeOnClose: true, closeOnBlur: true, openOnConnect: true })

    const frame = document.createElement("turbo-frame")
    frame.id = this.frameNameValue
    frame.src = this.element.href
    frame.classList.add("block", "w-full")

    const loading = document.createElement("div")
    loading.classList.add("rounded", "p-4", "bg-white", "dark:bg-neutral-900", "dark:border", "dark:border-neutral-500")
    loading.textContent = "Loading..."

    frame.appendChild(loading)
    this.#dialog.appendChild(frame)

    this.#dialog.setAttribute("aria-label", this.frameNameValue)

    if (this.hasClassValue) this.classValue.split(" ").forEach((klass) => this.#dialog.classList.add(klass))

    if (this.hasDataAttributesValue) {
      Object.entries(this.dataAttributesValue).forEach(([key, value]) => {
        this.#dialog.dataset[key] = value
      })
    }

    document.body.appendChild(this.#dialog)
  }

  // Private

  #dialog
}
