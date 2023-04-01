import ApplicationController from "controllers/application_controller"
import Dialog from "models/dialog"

export default class extends ApplicationController {
  connect() {
    this.element.classList.add("cursor-zoom-in")
    let action = this.element.dataset.action || ""

    if (action.length > 0) action += " "
    action += "click->enlarge-figure#enlarge"

    this.element.dataset.action = action
  }

  enlarge(event) {
    event.preventDefault()

    const dialog = Dialog.create({ closeOnBlur: true, removeOnClose: true })
    document.body.appendChild(dialog)

    dialog.classList.add("backdrop:backdrop-blur-md")
    dialog.classList.add("rounded")
    dialog.classList.add("shadow-lg")
    dialog.innerHTML = `
      <div class="flex flex-col items-center align-center">
        ${this.element.innerHTML}
      </div>
    `

    dialog.showModal()
  }
}
