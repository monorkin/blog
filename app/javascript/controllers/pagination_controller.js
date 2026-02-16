import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static targets = ["link"]

  // Lifecycle

  initialize() {
    this.#observer = new IntersectionObserver(entries => {
      for (const entry of entries) {
        if (entry.isIntersecting) this.#loadPage(entry.target)
      }
    }, { rootMargin: "400px" })
  }

  linkTargetConnected(element) {
    this.#observer.observe(element)
  }

  linkTargetDisconnected(element) {
    this.#observer.unobserve(element)
  }

  disconnect() {
    this.#observer.disconnect()
  }

  // Private

  #observer

  #loadPage(link) {
    this.#observer.unobserve(link)

    const frame = document.createElement("turbo-frame")
    frame.id = link.dataset.turboFrame
    frame.src = link.href
    frame.loading = "eager"

    link.replaceWith(frame)
  }
}
