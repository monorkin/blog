import ApplicationController from "controllers/application_controller"
import Dialog from "models/dialog"

export default class extends ApplicationController {
  static values = {
    url: String
  }

  enlarge(event) {
    event.preventDefault()

    if (!this.hasUrlValue) return

    const dialog = Dialog.create({ closeOnBlur: true, removeOnClose: true })
    document.body.appendChild(dialog)

    dialog.classList.add("backdrop:backdrop-blur-md")
    dialog.classList.add("rounded")
    dialog.classList.add("shadow-lg")
    dialog.innerHTML = `
      <div class="flex flex-col items-center align-center">
        <img src="${this.urlValue}" class="w-auto max-h-[80vh]">
      </div>
    `

    dialog.showModal()
  }
}
