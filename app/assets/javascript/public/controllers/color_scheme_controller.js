import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "switch" ]
  static classes = [ "light", "dark", "auto" ]

  LIGHT = 'light'
  DARK = 'dark'
  AUTO = 'auto'
  STORAGE_KEY = 'colorScheme'

  connect() {
    if (this.hasSwitchTarget) {
      this.switchTarget.classList.remove('hidden')
    }

    const currentMode = localStorage.getItem(this.STORAGE_KEY)
    const preferredMode = this.browserPreferredColorScheme()
    this.useMode(currentMode || preferredMode)
  }

  toggleMode(event) {
    event.preventDefault()

    if (this.currentMode() === this.LIGHT) {
      this.useMode(this.DARK)
    }
    else {
      this.useMode(this.LIGHT)
    }
  }

  currentMode() {
    if (this.element.classList.contains(this.autoClass)) {
      return this.AUTO
    }
    else if (this.element.classList.contains(this.darkClass)) {
      return this.DARK
    }

    return this.LIGHT
  }

  useMode(mode) {
    if (!this.colorSchemeClassesPresent) {
      return
    }

    let klass = this.lightClass

    if (mode === this.DARK) {
      klass = this.darkClass
    }

    localStorage.setItem(this.STORAGE_KEY, mode)

    this.activateClass(klass)
  }

  colorSchemeClassesPresent() {
    return this.hasLightClass && this.hasDarkClass && this.hasAutoClass
  }

  activateClass(klass) {
    this.element.classList.remove(this.lightClass)
    this.element.classList.remove(this.darkClass)
    this.element.classList.remove(this.autoClass)
    this.element.classList.add(klass)
  }

  browserPreferredColorScheme() {
    if(!window.matchMedia) {
      return this.LIGHT
    }

    const mqList = window.matchMedia('(prefers-color-scheme: dark)')
    if (mqList.matches) {
      return this.DARK
    }

    return this.LIGHT
  }
}
