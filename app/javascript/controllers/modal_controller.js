import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static targets = [ "modalWindow" ]

  toggle(event) {
    if (this.shown) {
      this.hide(event)
    }
    else {
      this.show(event)
    }
  }

  show(event) {
    if (!this.hasModalWindowTarget) return

    this.modalWindowTarget.showModal()
  }

  hide(event) {
    if (!this.hasModalWindowTarget) return

    this.modalWindowTarget.close()
  }

  get shown() {
    if (!this.hasModalWindowTarget) return false

    return this.modalWindowTarget.open
  }

  get hidden() {
    !this.shown
  }

  handleBackdropInteraction(event) {
    if (!this.hasModalWindowTarget) return

    const modalBounds = this.modalWindowTarget.getBoundingClientRect()

    if (this.pointInRect([event.clientX, event.clientY], modalBounds)) return

    this.hide()
  }

  pointInRect(point, rect) {
    const x = point[0]
    const y = point[1]

    return (
      rect.top <= y &&
      rect.top + rect.height >= y &&
      rect.left <= x &&
      rect.left + rect.width >= x
    )
  }
}
