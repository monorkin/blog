import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static targets = [ "hiddenInput", "textInput", "tagList", "suggestions" ]
  static values = {
    suggestionsUrl: String,
    tags: { type: Array, default: [] }
  }

  // Lifecycle

  initialize() {
    this.#fetchController = null

    // Read initial tags from the server-rendered hidden input before
    // the value observer fires tagsValueChanged with the empty default
    const input = this.element.querySelector('[data-tag-input-target="hiddenInput"]')
    const initial = input?.value || ""
    if (initial.trim().length > 0) {
      this.tagsValue = initial.split(",").map(t => t.trim()).filter(t => t.length > 0)
    }
  }

  disconnect() {
    if (this.#fetchController) this.#fetchController.abort()
  }

  tagsValueChanged() {
    this.hiddenInputTarget.value = this.tagsValue.join(", ")
    this.#renderPills()
  }

  // Actions

  search() {
    const query = this.textInputTarget.value.trim()
    if (query.length === 0) {
      this.closeSuggestions()
      return
    }

    this.#fetchSuggestions(query)
  }

  navigate(event) {
    this.#keyHandlers[event.key]?.call(this, event)
  }

  addTag(name) {
    if (!this.tagsValue.includes(name)) {
      this.tagsValue = [ ...this.tagsValue, name ]
    }
    this.textInputTarget.value = ""
    this.closeSuggestions()
  }

  removeTag({ currentTarget }) {
    this.tagsValue = this.tagsValue.filter(t => t !== currentTarget.dataset.tagName)
    this.textInputTarget.focus()
  }

  selectSuggestion({ currentTarget }) {
    this.addTag(currentTarget.dataset.name)
  }

  closeSuggestions() {
    this.suggestionsTarget.classList.add("hidden")
    this.suggestionsTarget.replaceChildren()
  }

  closeOnClickOutside({ target }) {
    if (!this.element.contains(target)) this.closeSuggestions()
  }

  focusInput() {
    this.textInputTarget.focus()
  }

  // Private

  #fetchController

  #addFromInput() {
    const name = this.#normalizeTag(this.textInputTarget.value)
    if (name.length > 0) this.addTag(name)
  }

  #removeLastTag() {
    if (this.textInputTarget.value === "" && this.tagsValue.length > 0) {
      this.tagsValue = this.tagsValue.slice(0, -1)
    }
  }

  async #fetchSuggestions(query) {
    if (this.#fetchController) this.#fetchController.abort()
    this.#fetchController = new AbortController()

    try {
      const url = new URL(this.suggestionsUrlValue, window.location.origin)
      url.searchParams.set("query", query)

      const response = await fetch(url, { signal: this.#fetchController.signal })
      const names = await response.json()

      if (this.textInputTarget.value.trim() !== query) return

      this.#renderSuggestions(names.filter(n => !this.tagsValue.includes(n)))
    } catch (e) {
      if (e.name !== "AbortError") throw e
    }
  }

  #renderSuggestions(names) {
    const list = this.suggestionsTarget

    if (names.length === 0) {
      list.classList.add("hidden")
      list.replaceChildren()
      return
    }

    list.replaceChildren(...names.map((name) => {
      const li = document.createElement("li")
      li.className = "px-3 py-1.5 cursor-pointer text-sm text-black aria-selected:bg-indigo-100"
      li.setAttribute("aria-selected", "false")
      li.dataset.name = name
      li.dataset.navigableListTarget = "item"
      li.dataset.action = "click->tag-input#selectSuggestion mouseenter->navigable-list#hoverSelect"
      li.textContent = name
      return li
    }))

    list.classList.remove("hidden")
  }

  #renderPills() {
    this.tagListTarget.replaceChildren(...this.tagsValue.map(name => {
      const pill = document.createElement("span")
      pill.className = "inline-flex items-center gap-0.5 px-2 py-0.5 rounded-full text-xs bg-indigo-100 text-indigo-800 dark:bg-yellow-300 dark:text-neutral-700"

      const label = document.createTextNode(name)
      pill.appendChild(label)

      const button = document.createElement("button")
      button.type = "button"
      button.dataset.action = "tag-input#removeTag"
      button.dataset.tagName = name
      button.className = "ml-0.5 hover:text-indigo-500 dark:hover:text-neutral-900 cursor-pointer"
      button.textContent = "\u00d7"
      pill.appendChild(button)

      return pill
    }))
  }

  #normalizeTag(value) {
    return value.trim().toLowerCase().replace(/[^0-9a-z]/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "")
  }

  #keyHandlers = {
    Enter(event) {
      if (event.defaultPrevented) return
      event.preventDefault()
      this.#addFromInput()
    },
    ","(event) {
      event.preventDefault()
      this.#addFromInput()
    },
    Backspace() {
      this.#removeLastTag()
    },
    Escape() {
      this.closeSuggestions()
    }
  }
}
