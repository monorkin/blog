import ApplicationController from "controllers/application_controller"
import { debounce } from "helpers/timing_helpers"

const DEBOUNCE_DELAY = 300

export default class extends ApplicationController {
  static targets = [ "form" ]

  // Lifecycle

  initialize() {
    this.search = debounce(this.search.bind(this), DEBOUNCE_DELAY)
  }

  // Actions

  search() {
    this.formTarget.requestSubmit()
  }
}
