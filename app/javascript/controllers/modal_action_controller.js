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

  connect() {
    if (!this.hasFrameNameValue) {
      throw new Error("You must specify a frame name with data-modal-action-frame-name-value")
    }

    this.element.addEventListener("click", this.openModal.bind(this))
  }

  disconnect() {
    this.dialog?.close()
  }

  openModal(event) {
    event.preventDefault()

    this.dialog = Dialog.create({ removeOnClose: true, closeOnBlur: true, openOnConnect: true })

    this.dialog.innerHTML = `
      <turbo-frame id="${this.frameNameValue}" src="${this.element.href}" class="block w-full">
        <div class="rounded p-4 bg-white dark:bg-neutral-900 dark:border dark:border-neutral-500">
          Loading...
        </div>
      </turbo-frame>
    `

    this.dialog.setAttribute("aria-label", this.frameNameValue)

    this.dialog.classList.add("w-full", "md:w-2/3", "bg-transparent",
      "backdrop:backdrop-blur-lg", "group")

    if (this.hasClassValue) this.classValue.split(" ").forEach((klass) => this.dialog.classList.add(klass))

    if (this.hasDataAttributesValue) {
      Object.entries(this.dataAttributesValue).forEach(([key, value]) => {
        this.dialog.dataset[key] = value
      })
    }

    document.body.appendChild(this.dialog)
  }
}
