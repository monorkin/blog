import ApplicationController from "controllers/application_controller"

export default class extends ApplicationController {
  static targets = [ "editor" ]
  static classes = [ "loading", "ready" ]

  async initialize() {
    await import("initializers/rich_text")
  }

  connect() {
    this.element.classList.remove(this.readyClass)
    this.element.classList.add(this.loadingClass)
  }

  editorReady() {
    this.element.classList.add(this.readyClass)
    this.element.classList.remove(this.loadingClass)
    this.#addYamlLanguageOption()
  }

  // Private

  #addYamlLanguageOption() {
    for (const select of this.element.querySelectorAll(".lexxy-code-language-picker")) {
      if (select.querySelector('option[value="yaml"]')) continue

      const option = document.createElement("option")
      option.value = "yaml"
      option.textContent = "YAML"

      const insertBefore = Array.from(select.options).find(o => o.textContent.localeCompare("YAML") > 0)
      select.insertBefore(option, insertBefore || null)
    }
  }
}
