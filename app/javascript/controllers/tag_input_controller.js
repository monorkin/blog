import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static targets = ["hiddenInput", "textInput", "tagList", "suggestions"]
  static values = {
    suggestionsUrl: String,
    tags: { type: Array, default: [] }
  }

  connect() {
    const initial = this.hiddenInputTarget.value
    if (initial.trim().length > 0) {
      this.tagsValue = initial.split(",").map(t => t.trim()).filter(t => t.length > 0)
    }

    this.highlightedIndex = -1
    this.fetchController = null
    this.debounceTimer = null

    this.outsideClickHandler = (event) => {
      if (!this.element.contains(event.target)) {
        this.closeSuggestions()
      }
    }
    document.addEventListener("click", this.outsideClickHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClickHandler)
    if (this.debounceTimer) clearTimeout(this.debounceTimer)
    if (this.fetchController) this.fetchController.abort()
  }

  tagsValueChanged() {
    this.hiddenInputTarget.value = this.tagsValue.join(", ")
    this.renderPills()
  }

  // --- Input handling ---

  onInput() {
    const query = this.textInputTarget.value.trim()
    if (query.length === 0) {
      this.closeSuggestions()
      return
    }

    if (this.debounceTimer) clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => this.fetchSuggestions(query), 200)
  }

  onKeydown(event) {
    switch (event.key) {
      case "Enter":
        event.preventDefault()
        if (this.highlightedIndex >= 0) {
          this.addHighlightedSuggestion()
        } else {
          this.addFromInput()
        }
        break
      case ",":
        event.preventDefault()
        this.addFromInput()
        break
      case "Backspace":
        if (this.textInputTarget.value === "" && this.tagsValue.length > 0) {
          this.tagsValue = this.tagsValue.slice(0, -1)
        }
        break
      case "ArrowDown":
        event.preventDefault()
        this.moveHighlight(1)
        break
      case "ArrowUp":
        event.preventDefault()
        this.moveHighlight(-1)
        break
      case "Escape":
        this.closeSuggestions()
        break
    }
  }

  // --- Tag management ---

  addFromInput() {
    const name = this.normalizeTag(this.textInputTarget.value)
    if (name.length > 0) {
      this.addTag(name)
    }
  }

  addTag(name) {
    if (!this.tagsValue.includes(name)) {
      this.tagsValue = [...this.tagsValue, name]
    }
    this.textInputTarget.value = ""
    this.closeSuggestions()
  }

  removeTag(event) {
    const name = event.currentTarget.dataset.tagName
    this.tagsValue = this.tagsValue.filter(t => t !== name)
    this.textInputTarget.focus()
  }

  // --- Suggestions ---

  async fetchSuggestions(query) {
    if (this.fetchController) this.fetchController.abort()

    this.fetchController = new AbortController()
    const sentQuery = query

    try {
      const url = new URL(this.suggestionsUrlValue, window.location.origin)
      url.searchParams.set("query", query)

      const response = await fetch(url, { signal: this.fetchController.signal })
      const names = await response.json()

      // Stale-response guard
      if (this.textInputTarget.value.trim() !== sentQuery) return

      const filtered = names.filter(n => !this.tagsValue.includes(n))
      this.renderSuggestions(filtered)
    } catch (e) {
      if (e.name !== "AbortError") throw e
    }
  }

  renderSuggestions(names) {
    this.highlightedIndex = -1
    const list = this.suggestionsTarget

    if (names.length === 0) {
      list.classList.add("hidden")
      list.innerHTML = ""
      return
    }

    list.innerHTML = names.map((name, i) =>
      `<li class="px-3 py-1.5 cursor-pointer hover:bg-indigo-100 text-sm text-black"
           data-index="${i}" data-name="${name}"
           data-action="click->tag-input#selectSuggestion">${this.escapeHtml(name)}</li>`
    ).join("")

    list.classList.remove("hidden")
  }

  selectSuggestion(event) {
    this.addTag(event.currentTarget.dataset.name)
  }

  addHighlightedSuggestion() {
    const items = this.suggestionsTarget.querySelectorAll("li")
    if (this.highlightedIndex >= 0 && this.highlightedIndex < items.length) {
      this.addTag(items[this.highlightedIndex].dataset.name)
    }
  }

  moveHighlight(direction) {
    const items = this.suggestionsTarget.querySelectorAll("li")
    if (items.length === 0) return

    items.forEach(li => li.classList.remove("bg-indigo-100"))

    this.highlightedIndex += direction
    if (this.highlightedIndex < 0) this.highlightedIndex = items.length - 1
    if (this.highlightedIndex >= items.length) this.highlightedIndex = 0

    items[this.highlightedIndex].classList.add("bg-indigo-100")
    items[this.highlightedIndex].scrollIntoView({ block: "nearest" })
  }

  closeSuggestions() {
    this.highlightedIndex = -1
    this.suggestionsTarget.classList.add("hidden")
    this.suggestionsTarget.innerHTML = ""
  }

  // --- Pills ---

  renderPills() {
    this.tagListTarget.innerHTML = this.tagsValue.map(name =>
      `<span class="inline-flex items-center gap-0.5 px-2 py-0.5 rounded-full text-xs
                    bg-indigo-100 text-indigo-800 dark:bg-yellow-300 dark:text-neutral-700">
        ${this.escapeHtml(name)}
        <button type="button" data-action="tag-input#removeTag" data-tag-name="${this.escapeHtml(name)}"
                class="ml-0.5 hover:text-indigo-500 dark:hover:text-neutral-900 cursor-pointer">&times;</button>
      </span>`
    ).join("")
  }

  focusInput() {
    this.textInputTarget.focus()
  }

  // --- Utilities ---

  normalizeTag(value) {
    return value.trim().toLowerCase().replace(/[^0-9a-z]/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
