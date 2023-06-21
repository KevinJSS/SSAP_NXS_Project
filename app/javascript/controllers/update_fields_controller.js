import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="update-fields"
export default class extends Controller {
  connect() {
    const children = this.element.childNodes;
    const selectList = children[7];

    for (let i = 0; i < selectList.length; i++) {
      if (selectList[i].value == children[1].value) {
        children[3].value = selectList[i].text;

        if (this.element.dataset.formModel == "minutes") {
          children[5].value = selectList[i].dataset.jobPosition;
        }
      }
    }
  }
}
