import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static classes = [ "active" ]

  // Actions

  toggle() {
    for (const className of this.activeClasses) {
      this.element.classList.toggle(className)
    }
  }
}
