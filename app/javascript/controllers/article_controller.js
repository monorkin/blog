import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  connect() {
    this.attachLinkPreviewControllers()
    // this.attachFigureEnlargementControllers()
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

  attachFigureEnlargementControllers() {
    for(const element of this.element.querySelectorAll("figure")) {
      this.attachFigureEnlargmentControllerTo(element)
    }
  }

  attachFigureEnlargmentControllerTo(element) {
    this.addControllerIfMissing(element, "enlarge-figure")
  }

  addControllerIfMissing(element, controller) {
    let controllers = element.dataset.controller || ""

    element.dataset.controller = this.appendTokenTo(controller, controllers)
  }
}
