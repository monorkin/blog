import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  click(event) {
    if (this.#isClickable && !this.#shouldIgnore(event)) {
      event.preventDefault()
      this.element.click()
    }
  }

  focus(event) {
    if (this.#isClickable && !this.#shouldIgnore(event)) {
      event.preventDefault()
      this.element.focus()
    }
  }

  // Private

  #shouldIgnore(event) {
    return event.defaultPrevented || event.target.closest("input, textarea, [contenteditable]")
  }

  get #isClickable() {
    return getComputedStyle(this.element).pointerEvents !== "none"
  }
}
