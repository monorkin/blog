import ApplicationController from "controllers/application_controller"
import Cookie from "models/cookie"

export default class extends ApplicationController {
  static targets = [ "lightColorSchemeInput", "darkColorSchemeInput", "systemColorSchemeInput" ]
  static classes = [ "light", "dark" ]

  LIGHT = 'light'
  DARK = 'dark'
  AUTO = 'auto'
  STORAGE_KEY = 'color_scheme'

  connect() {
    this.useColorScheme(this.currentColorScheme)
    window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", this.autoSwitchColorScheme.bind(this))
  }

  disconnect() {
    window.matchMedia("(prefers-color-scheme: dark)").removeEventListener("change", this.autoSwitchColorScheme.bind(this))
  }

  autoSwitchColorScheme(event) {
    if (this.currentColorScheme !== this.AUTO) return

    this.useColorScheme(this.AUTO)
  }

  useLightColorScheme(event) {
    this.useColorScheme(this.LIGHT)
  }

  useDarkColorScheme(event) {
    this.useColorScheme(this.DARK)
  }

  useSystemColorScheme(event) {
    this.useColorScheme(this.AUTO)
  }

  useColorScheme(scheme) {
    Cookie.set(this.STORAGE_KEY, scheme)

    if (scheme === this.AUTO && this.hasSystemColorSchemeInputTarget) {
      this.systemColorSchemeInputTarget.checked = true
    }
    else if (scheme === this.DARK && this.hasDarkColorSchemeInputTarget) {
      this.darkColorSchemeInputTarget.checked = true
    }
    else if (scheme === this.LIGHT && this.hasLightColorSchemeInputTarget) {
      this.lightColorSchemeInputTarget.checked = true
    }

    if (scheme === this.AUTO) scheme = this.systemColorScheme

    const currentSchemeClass = scheme === this.DARK ? this.darkClass : this.lightClass
    const previousSchemeClass = scheme === this.DARK ? this.lightClass : this.darkClass

    this.element.classList.remove(previousSchemeClass)
    this.element.classList.add(currentSchemeClass)
  }

  get currentColorScheme() {
    const storedValue = Cookie.get(this.STORAGE_KEY)

    if (!storedValue) return this.AUTO

    return storedValue
  }

  get systemColorScheme() {
    const colorSchemeQueryList = window.matchMedia('(prefers-color-scheme: dark)');

    if (colorSchemeQueryList.matches) {
      return this.DARK
    }
    else {
      return this.LIGHT
    }
  }
}
