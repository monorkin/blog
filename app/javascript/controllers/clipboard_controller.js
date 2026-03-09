import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static values = { text: String, confirmationDuration: { type: Number, default: 1500 } }
  static classes = [ "copied" ]

  #timer

  // Actions

  copy() {
    navigator.clipboard.writeText(this.textValue).then(() => {
      this.#showConfirmation()
    })
  }

  // Private

  #showConfirmation() {
    if (!this.hasCopiedClass) return

    this.element.classList.add(this.copiedClass)
    clearTimeout(this.#timer)
    this.#timer = setTimeout(() => {
      this.element.classList.remove(this.copiedClass)
    }, this.confirmationDurationValue)
  }
}
