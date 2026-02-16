import ApplicationController from "controllers/application_controller"

const HIDDEN_CLASS = "hidden"
const VIEWPORT_MARGIN = 8

export default class extends ApplicationController {
  static values = {
    baseUrl: String,
    url: String,
    id: String
  }

  // Lifecycle

  connect() {
    this.#shown = false
    if (!this.baseUrlValue) this.baseUrlValue = `${window.location.pathname}/link_previews`
    if (!this.hasUrlValue) this.urlValue = this.element.href
  }

  disconnect() {
    this.#shown = false
    if (this.#popupElement) this.#popupElement.remove()
  }

  // Actions

  show() {
    this.#shown = true
    this.#showPopupIfContentExists()
  }

  hide() {
    this.#shown = false
    if (this.#popupElement) this.#popupElement.classList.add(HIDDEN_CLASS)
  }

  // Private

  #popupElement
  #shown
  #cachedContentExistsResult

  async #showPopupIfContentExists() {
    const contentExists = await this.#cachedContentExists()

    if (!contentExists || !this.#shown) return
    this.#showPopup()
  }

  #showPopup() {
    if (!this.#popupElement) this.#createPopup()
    this.#popupElement.classList.remove(HIDDEN_CLASS)
    this.#position()
  }

  #createPopup() {
    this.#popupElement = document.createElement("div")
    this.#popupElement.classList.add(HIDDEN_CLASS, "popup")

    const container = document.createElement("div")
    container.classList.add("popup__container")

    const arrow = document.createElement("div")
    arrow.classList.add("popup__container__arrow")
    container.appendChild(arrow)

    const frame = document.createElement("turbo-frame")
    frame.id = `link_preview-${this.#previewId}`
    frame.classList.add("popup__container__content")
    frame.src = this.#previewUrl

    const loadingIndicator = document.createElement("div")
    loadingIndicator.classList.add("popup__container__content__loading-indicator")

    const spinner = document.createElement("span")
    spinner.classList.add("spinner")
    loadingIndicator.appendChild(spinner)
    loadingIndicator.appendChild(document.createTextNode(" Loading preview..."))

    frame.appendChild(loadingIndicator)
    container.appendChild(frame)
    this.#popupElement.appendChild(container)

    this.element.style.position = "relative"
    this.element.appendChild(this.#popupElement)
  }

  #position() {
    if (!this.#popupElement) return

    const popup = this.#popupElement
    const arrow = popup.querySelector(".popup__container__arrow")
    const linkRect = this.element.getBoundingClientRect()
    const popupRect = popup.getBoundingClientRect()
    const spaceBelow = window.innerHeight - linkRect.bottom
    const placement = spaceBelow >= popupRect.height + VIEWPORT_MARGIN ? "bottom" : "top"

    popup.style.position = "absolute"
    popup.style.left = "50%"
    popup.style.transform = "translateX(-50%)"
    popup.dataset.placement = placement

    if (placement === "bottom") {
      popup.style.top = "100%"
      popup.style.bottom = "auto"
    } else {
      popup.style.bottom = "100%"
      popup.style.top = "auto"
    }

    // Reset arrow to center before clamping
    arrow.style.left = "50%"
    arrow.style.transform = "translateX(-50%)"

    // Clamp popup within viewport, shifting the arrow to stay over the link
    requestAnimationFrame(() => {
      const rect = popup.getBoundingClientRect()
      let shift = 0

      if (rect.right > window.innerWidth - VIEWPORT_MARGIN) {
        shift = window.innerWidth - VIEWPORT_MARGIN - rect.right
      } else if (rect.left < VIEWPORT_MARGIN) {
        shift = VIEWPORT_MARGIN - rect.left
      }

      if (shift !== 0) {
        popup.style.transform = `translateX(calc(-50% + ${shift}px))`
        arrow.style.transform = `translateX(calc(-50% - ${shift}px))`
      }
    })
  }

  async #cachedContentExists() {
    if (typeof(this.#cachedContentExistsResult) === "undefined") {
      this.#cachedContentExistsResult = await this.#contentExists()
    }

    return this.#cachedContentExistsResult
  }

  async #contentExists() {
    let headers = {
      "Content-Type": "text/html"
    }

    const tokenElements = document.getElementsByName("csrf-token")
    if (tokenElements.length >= 1) headers["X-CSRF-Token"] = tokenElements[0].content

    const response = await fetch(
      this.#previewUrl,
      {
        method: "HEAD",
        mode: "cors",
        headers: headers,
        redirect: "error",
        referrerPolicy: "no-referrer"
      }
    )

    return (response.status >= 200 && response.status < 300)
  }

  get #previewUrl() {
    return `${this.baseUrlValue}/${this.#previewId}`
  }

  get #previewId() {
    if (!this.hasUrlValue) return null

    return btoa(this.urlValue).replace(/\//g, '_').replace(/\+/g, '-')
  }
}
