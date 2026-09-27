import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static classes = [ "loaded" ]

  // Lifecycle

  connect() {
    if (this.element.complete) {
      this.markLoaded()
    }
  }

  // Actions

  markLoaded() {
    this.element.classList.add(...this.loadedClasses)
  }
}
