import { Controller } from "stimulus"
import { createPopper } from '@popperjs/core';

export default class extends Controller {
  static targets = [ "popup" ]
  static values = {
    baseUrl: String,
    url: String,
    id: String
  }
  HIDDEN_CLASS = 'hidden'

  connect() {
    if (!this.baseUrlValue) this.baseUrlValue = `${window.location.pathname}/link_previews`
    if (!this.hasUrlValue) this.urlValue = this.element.href
  }

  disconnect() {
    if (this.popup) this.popup.destroy()
  }

  show() {
    this.showPopupIfContentExists()
  }

  hide() {
    if (this.hasPopupTarget) this.popupTarget.classList.add(this.HIDDEN_CLASS)
    if (this.popup) this.popup.update()
  }

  async showPopupIfContentExists() {
    const contentExists = await this.cachedContentExists()

    if (!contentExists) return
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
    popupContent.classList.add('popup--within_content')
    popupContent.dataset.linkPreviewTarget = 'popup'
    popupContent.innerHTML = `
      <div class="popup__container">
        <div data-popper-arrow class="popup__container__arrow"></div>
        <turbo-frame id="link_preview-${this.idValue}" class="popup__container__content" src="${this.previewUrl}">
          <span class="spinner"></span> Loading preview...
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
