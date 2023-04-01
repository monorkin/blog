import ApplicationModel from "models/application_model"
import Trix from "trix"

export default class extends ApplicationModel {
  static register() {
    const buttonHTML =
      `<button type="button"
         class="trix-button trix-button--icon trix-button--icon-table"
         title="table" tabindex="-1"
         data-action="trix-table#attachTable">table</button>`;

    const buttonGroupElement = document
      .querySelector("trix-editor")
      .toolbarElement.querySelector("[data-trix-button-group=file-tools]");

    buttonGroupElement.insertAdjacentHTML("beforeend", buttonHTML);
  }
}
