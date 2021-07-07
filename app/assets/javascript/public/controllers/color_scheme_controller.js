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

    this.useMode(this.storedMode)
  }

  toggleMode(event) {
    event.preventDefault()

    const newScheme = (this.currentMode === this.LIGHT) ? this.DARK : this.LIGHT

    // Crude way to unset your preference.
    //
    // If you set the toggle to you current system's preference then your
    // system's preference will be used as the preference henceforth.
    if (newScheme === this.browserPreferredColorScheme) {
      this.useMode(this.AUTO)
    }
    else {
      this.useMode(newScheme)
    }
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
  }

  activateClass(klass) {
    this.element.classList.remove(this.lightClass)
    this.element.classList.remove(this.darkClass)
    this.element.classList.remove(this.autoClass)
    this.element.classList.add(klass)
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

    return this.browserPreferredColorScheme
  }

}
