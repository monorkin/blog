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
    this.element.querySelectorAll(".header__container__actions__dropdown__content").forEach((e) => e.classList.remove("hidden"))
    this.element.style.top = 0

    if (window.scrollY > 0) {
      this.element.classList.add("header--floating")
    }
    else {
      this.element.classList.remove("header--floating")
    }
  }

  hide() {
    this.element.querySelectorAll(".header__container__actions__dropdown__content").forEach((e) => e.classList.add("hidden"))
    this.element.classList.remove("header--floating")
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
