import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static outlets = [ "dialog" ]

  openMenu(event) {
    event.preventDefault()

    if (!this.hasDialogOutlet) return

    this.dialogOutlet.open()
  }
}
