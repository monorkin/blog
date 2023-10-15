import ApplicationModel from 'models/application_model'

export default class extends ApplicationModel {
  static create (options) {
    options = options || {}

    const element = document.createElement('dialog')
    element.dataset.controller = 'dialog'
    element.dataset.action = 'close->dialog#handleClose'
    element.dataset.openOnConnect = options.openOnConnect || false

    if (options.removeOnClose) element.dataset.dialogRemoveOnCloseValue = true
    if (options.closeOnBlur) {
      element.dataset.action = element.dataset.action || ""
      if (element.dataset.action.length > 0) element.dataset.action += " "
      element.dataset.action += "click->dialog#closeOnOutsideClick"
    }

    return element
  }
}
