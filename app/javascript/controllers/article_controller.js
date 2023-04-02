import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  connect() {
    this.attachLinkPreviewControllers()
  }

  attachLinkPreviewControllers() {
    for(const element of this.element.querySelectorAll("a")) {
      this.attachLinkPreviewControllerTo(element)
    }
  }

  attachLinkPreviewControllerTo(element) {
    element.dataset.action = this.appendTokenTo("mouseover->link-preview#show", element.dataset.action)
    element.dataset.action = this.appendTokenTo("mouseout->link-preview#hide", element.dataset.action)
    this.addControllerIfMissing(element, "link-preview")
  }

  addControllerIfMissing(element, controller) {
    let controllers = element.dataset.controller || ""

    element.dataset.controller = this.appendTokenTo(controller, controllers)
  }
}
