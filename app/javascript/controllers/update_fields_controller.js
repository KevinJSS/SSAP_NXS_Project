import { Controller, add } from "@hotwired/stimulus"

// Connects to data-controller="update-fields"
export default class extends Controller {
  /**
   * The connect method is called when the controller is connected to an element.
   * It retrieves the dropdown list and its type from the DOM.
   * If the dropdown type is "form", it calls the updateDropdownForm method.
   * It then iterates through the dropdown list and updates the corresponding fields based on the selected value.
   */
  connect() {
    const children = this.element.childNodes;
    const dropdownList = children[7];
    const dropdownType = dropdownList.dataset.dropdownType;

    if (dropdownType && dropdownType == "form") {
      this.updateDropdownForm(dropdownList);
    }

    // Updates the activities name and hours fields, as well as the minutes users fullname and job position fields
    for (let i = 0; i < dropdownList.length; i++) {
      if (dropdownList[i].value == children[1].value) {
        children[3].value = dropdownList[i].text;

        if (this.element.dataset.formModel == "minutes") {
          children[5].value = dropdownList[i].dataset.jobPosition;
        }
      }
    }
  }

  /**
   * The updateDropdownForm method updates the dropdown list form.
   * It retrieves the necessary elements from the DOM, such as the parent container, items, search input, and hidden input.
   * It checks if a hidden input value is present, and if so, it matches the value with an item in the dropdown list.
   * If a match is found, it sets the search input value accordingly.
   * If no match is found, it checks for a hidden name value and sets the search input value to the default name if available.
   */
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
    
    const hiddenName = parent.querySelector("[data-id='hidden-name']");
    if (!added && hiddenName && hiddenName.value != "") {
      searchInput.value = hiddenName.defaultValue;
      return;
    }
  }
}
