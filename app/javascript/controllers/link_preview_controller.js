import { createPopper } from '@popperjs/core';
import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static targets = [ "popup" ]
  static values = {
    baseUrl: String,
    url: String,
    id: String
  }
  HIDDEN_CLASS = 'hidden'

  connect() {
    this.shown = false
    if (!this.baseUrlValue) this.baseUrlValue = `${window.location.pathname}/link_previews`
    if (!this.hasUrlValue) this.urlValue = this.element.href
  }

  disconnect() {
    this.shown = false
    if (this.popup) this.popup.destroy()
  }

  show() {
    this.shown = true
    this.showPopupIfContentExists()
  }

  hide() {
    this.shown = false
    if (this.hasPopupTarget) this.popupTarget.classList.add(this.HIDDEN_CLASS)
    if (this.popup) this.popup.update()
  }

  async showPopupIfContentExists() {
    const contentExists = await this.cachedContentExists()

    if (!contentExists || !this.shown) return
    this.showPopup()
  }

  showPopup() {
    if (!this.popup) this.createPopup()
    if (this.hasPopupTarget) this.popupTarget.classList.remove(this.HIDDEN_CLASS)
    if (this.popup) this.popup.update()
  }

  createPopup() {
    const popupContent = document.createElement('div')
    popupContent.classList.add('hidden')
    popupContent.classList.add('popup')
    popupContent.dataset.linkPreviewTarget = 'popup'
    popupContent.innerHTML = `
      <div class="popup__container">
        <div data-popper-arrow class="popup__container__arrow"></div>
        <turbo-frame id="link_preview-${this.idValue}" class="popup__container__content" src="${this.previewUrl}">
          <div class="popup__container__content__loading-indicator">
            <span class="spinner"></span> Loading preview...
          </div>
        </turbo-frame>
      </div>
    `
    this.element.appendChild(popupContent)

    if (!this.hasPopupTarget) return

    this.popup = createPopper(this.element, this.popupTarget, {
      placement: 'auto'
    });
  }

  async cachedContentExists() {
    if (typeof(this.cachedContentExistsResult) === "undefined") {
      this.cachedContentExistsResult = await this.contentExists()
    }

    return this.cachedContentExistsResult
  }

  async contentExists() {
    let headers = {
      "Content-Type": "text/html"
    }

    const tokenElements = document.getElementsByName("csrf-token")
    if (tokenElements.length >= 1) headers["X-CSRF-Token"] = tokenElements[0].content

    const response = await fetch(
      this.previewUrl,
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

  get previewUrl() {
    return `${this.baseUrlValue}/${encodeURI(this.idValue)}?url=${btoa(this.urlValue)}`
  }
}
