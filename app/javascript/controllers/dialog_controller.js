import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  static values = {
    removeOnClose: {
      type: Boolean,
      default: false
    }
  }

  connect() {
    if (this.element.dataset.openOnConnect === "true") this.open()
  }

  disconnect() {
    if (this.isOpen) this.handleClose()
  }

  open() {
    this.element.showModal()

    try {
      let count = JSON.parse(document.body.dataset.openDialogs || "0")
      document.body.dataset.openDialogs = count + 1
    } catch (e) {
      console.error("Failed to increment open dialog count", e)
      document.body.dataset.openDialogs = 1
    }

    document.body.classList.add('overflow-hidden')
  }

  close(event) {
    event?.preventDefault()
    this.element.close()
    this.handleClose(event)
  }

  handleClose() {
    try {
      let count = JSON.parse(document.body.dataset.openDialogs || "1")
      document.body.dataset.openDialogs = count - 1
    } catch (e) {
      console.error("Failed to decrement open dialog count", e)
      document.body.dataset.openDialogs = 0
    }

    if (document.body.dataset.openDialogs <= 0) {
      document.body.classList.remove('overflow-hidden')
    }

    if (this.removeOnCloseValue) this.element.remove()
  }

  closeOnOutsideClick(event) {
    if (event.target !== this.element) return

    const dialogBounds = this.element.getBoundingClientRect()

    const clickInsideDialog = (
      dialogBounds.top <= event.clientY &&
      event.clientY <= dialogBounds.top + dialogBounds.height &&
      dialogBounds.left <= event.clientX &&
      event.clientX <= dialogBounds.left + dialogBounds.width
    )

    if (!clickInsideDialog) this.close()
  }

  get isOpen() {
    return this.element.open
  }
}
