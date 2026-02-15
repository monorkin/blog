import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static targets = [ "item" ]
  static values = {
    selectionAttribute: { type: String, default: "aria-selected" }
  }

  // Lifecycle

  initialize() {
    this.#selectedIndex = -1
  }

  // Actions

  navigate(event) {
    this.#keyHandlers[event.key]?.call(this, event)
  }

  select({ currentTarget }) {
    this.#clickItem(currentTarget)
  }

  hoverSelect({ currentTarget }) {
    this.#highlight(this.itemTargets.indexOf(currentTarget))
  }

  reset() {
    this.#clearSelection()
    this.#selectedIndex = -1
  }

  // Private

  #selectedIndex

  #selectNext(event) {
    event.preventDefault()
    const items = this.itemTargets
    if (items.length === 0) return

    this.#highlight(this.#selectedIndex < items.length - 1 ? this.#selectedIndex + 1 : 0)
  }

  #selectPrevious(event) {
    event.preventDefault()
    const items = this.itemTargets
    if (items.length === 0) return

    this.#highlight(this.#selectedIndex > 0 ? this.#selectedIndex - 1 : items.length - 1)
  }

  #confirmSelection(event) {
    if (event.isComposing) return

    const items = this.itemTargets
    if (this.#selectedIndex >= 0 && this.#selectedIndex < items.length) {
      event.preventDefault()
      this.#clickItem(items[this.#selectedIndex])
    }
  }

  #clickItem(item) {
    const clickable = item.querySelector("a,button") || item
    clickable.click()
  }

  #highlight(index) {
    this.#clearSelection()
    this.#selectedIndex = index

    const items = this.itemTargets
    if (index >= 0 && index < items.length) {
      items[index].setAttribute(this.selectionAttributeValue, "true")
      items[index].scrollIntoView({ block: "nearest" })
    }
  }

  #clearSelection() {
    for (const item of this.itemTargets) {
      item.setAttribute(this.selectionAttributeValue, "false")
    }
  }

  #keyHandlers = {
    ArrowDown(event) {
      this.#selectNext(event)
    },
    ArrowUp(event) {
      this.#selectPrevious(event)
    },
    Enter(event) {
      this.#confirmSelection(event)
    }
  }
}
