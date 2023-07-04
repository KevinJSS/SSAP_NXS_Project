import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="update-fields"
export default class extends Controller {
  connect() {
    const children = this.element.childNodes;
    const selectList = children[7];

    const dropdownType = selectList.dataset.dropdownType;

    if (dropdownType && dropdownType == "form") {
      const parent = selectList.parentElement;
      const searchInput = parent.querySelector(".search-bar");
      const hiddenName = document.getElementById("hidden-name");

      const hiddenInput = parent.querySelector("[data-id='hidden-input']");
      if (hiddenInput && hiddenInput.value != "") {
        for (let i = 0; i < selectList.length; i++) {
          if (selectList[i].value == hiddenInput.value) {
            searchInput.value = selectList[i].text;
            return;
          }
        }
      }
      
      if (hiddenName && hiddenName.value != "") {
        searchInput.value = hiddenName.defaultValue;
        return;
      }
    }

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
