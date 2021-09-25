import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.lastYPosition = window.scrollY
    document.addEventListener("scroll", this.smartToggle.bind(this))
  }

  disconnect() {
    this.lastYPosition = null
    document.removeEventListener("scroll", this.smartToggle.bind(this))
  }

  smartToggle(event) {
    if (this.headerShouldBeShown) {
      this.directionChangeStartYPosition = null
      this.show()
    }
    else if (this.goingDown) {
      if (!this.previouslyGoing || this.previouslyGoing === "up") {
        this.directionChangeStartYPosition = window.scrollY
        this.previouslyGoing = "down"
      }

      if (window.scrollY >= this.directionChangeStartYPosition + this.treshold) this.hide()
    }
    else if (this.goingUp) {
      if (!this.previouslyGoing || this.previouslyGoing === "down") {
        this.directionChangeStartYPosition = window.scrollY
        this.previouslyGoing = "up"
      }

      if (window.scrollY <= this.directionChangeStartYPosition - this.treshold) this.show()
    }

    this.lastYPosition = window.scrollY
  }

  show() {
    this.element.style.top = 0
  }

  hide() {
    this.element.style.top = `${-1 * this.element.offsetHeight}px`
  }

  get treshold() {
    return this.element.offsetHeight
  }

  get goingDown() {
    return window.scrollY > this.lastYPosition
  }

  get goingUp() {
    return window.scrollY < this.lastYPosition
  }

  get headerShouldBeShown() {
    return window.scrollY <= this.treshold
  }
}
