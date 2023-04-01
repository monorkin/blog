import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  static values = {
    removeOnClose: {
      type: Boolean,
      default: false
    }
  }

  disconnect () {
    this.handleClose()
  }

  open () {
    this.element.showModal()
    document.body.dataset.openDialogs ||= 0
    document.body.dataset.openDialogs += 1
    document.body.classList.add('overflow-hidden')
  }

  close (event) {
    this.element.close()
    this.handleClose(event)
  }

  handleClose () {
    document.body.dataset.openDialogs ||= 1
    document.body.dataset.openDialogs -= 1

    if (document.body.dataset.openDialogs <= 0) {
      document.body.classList.remove('overflow-hidden')
    }

    if (this.removeOnCloseValue) this.element.remove()
  }

  closeOnOutsideClick (event) {
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
}
