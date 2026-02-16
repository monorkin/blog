import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static targets = ["publishedInput", "publishAtInput", "scheduleDatetime", "schedulePopup", "draftControls", "publishedControls"]
  static values = { published: Boolean }

  // Lifecycle

  publishedValueChanged() {
    if (this.publishedValue) {
      this.draftControlsTarget.hidden = true
      this.publishedControlsTarget.hidden = false
    } else {
      this.draftControlsTarget.hidden = false
      this.publishedControlsTarget.hidden = true
    }
  }

  // Actions

  publish() {
    this.publishedInputTarget.value = "true"
    this.publishAtInputTarget.value = ""
  }

  unpublish() {
    this.publishedInputTarget.value = "false"
  }

  toggleSchedule() {
    this.schedulePopupTarget.hidden = !this.schedulePopupTarget.hidden
  }

  publishAtTime() {
    this.publishAtInputTarget.value = this.scheduleDatetimeTarget.value
    this.publishedInputTarget.value = "true"
  }
}
