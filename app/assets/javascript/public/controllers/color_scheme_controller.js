import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "switch", "label" ]
  static classes = [ "light", "dark", "auto" ]
  static values = {
    autoLabel: String,
    lightLabel: String,
    darkLabel: String
  }

  LIGHT = 'light'
  DARK = 'dark'
  AUTO = 'auto'
  STORAGE_KEY = 'colorScheme'

  connect() {
    if (this.hasSwitchTarget) {
      this.switchTarget.classList.remove('hidden')
    }

    this.useMode(this.storedMode)
  }

  switchMode(event) {
    event.preventDefault()

    let newMode = null

    if (this.currentMode === this.AUTO) newMode = this.LIGHT
    else if (this.currentMode === this.LIGHT) newMode = this.DARK
    else if (this.currentMode === this.DARK) newMode = this.AUTO

    this.useMode(newMode)
  }

  useMode(mode) {
    if (!mode) return
    if (!this.colorSchemeClassesPresent) return

    let klass = this.autoClass

    if (mode === this.DARK) {
      klass = this.darkClass
    }
    else if (mode === this.LIGHT) {
      klass = this.lightClass
    }

    localStorage.setItem(this.STORAGE_KEY, mode)

    this.activateClass(klass)
    this.changeLabel(mode)
  }

  activateClass(klass) {
    this.element.classList.remove(this.lightClass)
    this.element.classList.remove(this.darkClass)
    this.element.classList.remove(this.autoClass)
    this.element.classList.add(klass)
  }

  changeLabel(mode) {
    if (!this.hasLabelTarget) return

    let newLabel = ""

    if (mode === this.AUTO && this.hasAutoLabelValue) {
      newLabel = this.autoLabelValue
    }
    else if (mode === this.LIGHT && this.hasLightLabelValue) {
      newLabel = this.lightLabelValue
    }
    else if (mode === this.DARK && this.hasDarkLabelValue) {
      newLabel = this.darkLabelValue
    }

    this.labelTarget.innerText = newLabel
  }

  get browserPreferredColorScheme() {
    if(!window.matchMedia) {
      return this.LIGHT
    }

    const mqList = window.matchMedia('(prefers-color-scheme: dark)')
    if (mqList.matches) {
      return this.DARK
    }

    return this.LIGHT
  }

  get colorSchemeClassesPresent() {
    return this.hasLightClass && this.hasDarkClass && this.hasAutoClass
  }

  get storedMode() {
    return localStorage.getItem(this.STORAGE_KEY)
  }

  get currentMode() {
    if (this.element.classList.contains(this.lightClass)) {
      return this.LIGHT
    }
    else if (this.element.classList.contains(this.darkClass)) {
      return this.DARK
    }
    else if (this.element.classList.contains(this.autoClass)) {
      return this.AUTO
    }

    return null
  }

}
