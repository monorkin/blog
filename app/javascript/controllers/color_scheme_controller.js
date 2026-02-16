import ApplicationController from "controllers/application_controller"
import Cookie from "models/cookie"

const LIGHT = "light"
const DARK = "dark"
const AUTO = "auto"
const STORAGE_KEY = "color_scheme"

export default class extends ApplicationController {
  static targets = [ "lightColorSchemeInput", "darkColorSchemeInput", "systemColorSchemeInput" ]
  static classes = [ "light", "dark" ]

  // Lifecycle

  connect() {
    this.#useColorScheme(this.#currentColorScheme)
    window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", this.#autoSwitchColorScheme)
  }

  disconnect() {
    window.matchMedia("(prefers-color-scheme: dark)").removeEventListener("change", this.#autoSwitchColorScheme)
  }

  lightColorSchemeInputTargetConnected(element) {
    if (this.#currentColorScheme !== LIGHT) return

    element.checked = true
  }

  darkColorSchemeInputTargetConnected(element) {
    if (this.#currentColorScheme !== DARK) return

    element.checked = true
  }

  systemColorSchemeInputTargetConnected(element) {
    if (this.#currentColorScheme !== AUTO) return

    element.checked = true
  }

  // Actions

  useLightColorScheme(event) {
    this.#useColorScheme(LIGHT)
  }

  useDarkColorScheme(event) {
    this.#useColorScheme(DARK)
  }

  useSystemColorScheme(event) {
    this.#useColorScheme(AUTO)
  }

  // Private

  #autoSwitchColorScheme = () => {
    if (this.#currentColorScheme !== AUTO) return

    this.#useColorScheme(AUTO)
  }

  #useColorScheme(scheme) {
    Cookie.set(STORAGE_KEY, scheme)

    if (scheme === AUTO && this.hasSystemColorSchemeInputTarget) {
      this.systemColorSchemeInputTarget.checked = true
    }
    else if (scheme === DARK && this.hasDarkColorSchemeInputTarget) {
      this.darkColorSchemeInputTarget.checked = true
    }
    else if (scheme === LIGHT && this.hasLightColorSchemeInputTarget) {
      this.lightColorSchemeInputTarget.checked = true
    }

    if (scheme === AUTO) scheme = this.#systemColorScheme

    const currentSchemeClass = scheme === DARK ? this.darkClass : this.lightClass
    const previousSchemeClass = scheme === DARK ? this.lightClass : this.darkClass

    this.element.classList.remove(previousSchemeClass)
    this.element.classList.add(currentSchemeClass)
  }

  get #currentColorScheme() {
    const storedValue = Cookie.get(STORAGE_KEY)

    if (!storedValue) return AUTO

    return storedValue
  }

  get #systemColorScheme() {
    const colorSchemeQueryList = window.matchMedia('(prefers-color-scheme: dark)');

    if (colorSchemeQueryList.matches) {
      return DARK
    }
    else {
      return LIGHT
    }
  }
}
