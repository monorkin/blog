import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static targets = [ "editor" ]
  static classes = [ "loading", "ready" ]

  async initialize() {
    await import("initializers/rich_text")
  }

  connect() {
    this.element.classList.remove(this.readyClass)
    this.element.classList.add(this.loadingClass)
  }

  editorReady() {
    this.element.classList.add(this.readyClass)
    this.element.classList.remove(this.loadingClass)
  }
}
