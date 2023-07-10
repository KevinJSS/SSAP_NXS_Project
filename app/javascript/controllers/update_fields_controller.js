import { Controller, add } from "@hotwired/stimulus"

// Connects to data-controller="update-fields"
export default class extends Controller {
  connect() {
    const children = this.element.childNodes;
    const dropdownList = children[7];
    const dropdownType = dropdownList.dataset.dropdownType;

    if (dropdownType && dropdownType == "form") {
      this.updateDropdownForm(dropdownList);
    }

    // Actualiza los campos de las listas de actividades y asistentes
    for (let i = 0; i < dropdownList.length; i++) {
      if (dropdownList[i].value == children[1].value) {
        children[3].value = dropdownList[i].text;

        if (this.element.dataset.formModel == "minutes") {
          children[5].value = dropdownList[i].dataset.jobPosition;
        }
      }
    }
  }

  updateDropdownForm(dropdownList) {
    const parent = dropdownList.parentElement;
    const items = dropdownList.querySelectorAll(".dropdown-list__item");
    const searchInput = parent.querySelector(".search-bar");
    const hiddenInput = parent.querySelector("[data-id='hidden-input']");

    let added = false;
    if (hiddenInput && hiddenInput.value != "") {
      for (let i = 0; i < items.length; i++) {
        if (items[i].dataset.value == hiddenInput.value) {
          searchInput.value = items[i].textContent.replace(/\n/g, "").trim();
          added = true;
          return;
        }
      }
    }
    
    //En caso de que el usuario este inactivo y no aparezca en la lista
    //Se busca el nombre en el hidden input
    const hiddenName = parent.querySelector("[data-id='hidden-name']");
    if (!added && hiddenName && hiddenName.value != "") {
      searchInput.value = hiddenName.defaultValue;
      return;
    }
  }
}
