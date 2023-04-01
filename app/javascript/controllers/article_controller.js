import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  connect() {
    this.attachLinkPreviewControllers()
    // this.attachFigureEnlargementControllers()
    this.highlightCodeSnippets()
  }

  attachLinkPreviewControllers() {
    for(const element of this.element.querySelectorAll("a")) {
      this.attachLinkPreviewControllerTo(element)
    }
  }

  attachLinkPreviewControllerTo(element) {
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
    if (controllers.includes(controller)) return

    if (controllers.lenth > 0) controllers += " "
    controllers += controller
    element.dataset.controller = controllers
  }

  highlightCodeSnippets() {
    for(const element of this.element.querySelectorAll("pre")) {
      this.highlightCodeSnippet(element)
    }
  }

  highlightCodeSnippet(element) {
    const code = element.innerHTML
    element.innerHTML = `<code>${code}</code>`
  }
}
