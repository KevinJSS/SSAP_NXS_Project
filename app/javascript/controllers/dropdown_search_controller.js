import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown-search"
export default class extends Controller {

  // The connect method is called when the controller is connected to an element.
  // It adds a click event listener to the document.
  connect() {
    document.addEventListener("click", this.handleClick);
  }

  // The disconnect method is called when the controller is disconnected from an element.
  // It removes the click event listener from the document.
  disconnect() {
    document.removeEventListener("click", this.handleClick);
  }

  /**
   * The handleClick method is the event handler for the click event on the document.
   * It checks if the click is outside the input and select elements and removes the active class if necessary.
   * If the click is outside the input and select elements, it removes the 'active' class from the input and dropdown list,
   * and sets the placeholder to "- Selecciona una opción -".
   */
  handleClick = (event) => {
    if (this.input === undefined ) return;

    //If the click is outside the input and select elements, remove the active class
    if (!this.input.contains(event.target) && !this.dropdownList.contains(event.target)) {
      this.input.classList.remove("active");
      this.dropdownList.classList.remove("active");
      this.input.placeholder = "- Selecciona una opción -";
    }
  }

  /**
   * The openDropdown method is called when the dropdown is opened.
   * It initializes the input, dropdownList, and map based on the dataset name.
   * It adds the 'active' class to the dropdown list and input elements,
   * and sets the placeholder to "Buscar...".
   */
  openDropdown(event) {
    this.input = event.target;
    const parent = this.input.parentElement;
    this.dropdownList = parent.querySelector(".dropdown-list");

    if (this.map == undefined || this.dataName != this.input.dataset.name) {
      this.loadMap(this.dropdownList);
    }

    this.dropdownList.classList.add("active");
    this.input.classList.add("active");
    this.input.placeholder = "Buscar...";
  }

  /**
   * The loadMap method initializes the map and stores the values of the dropdown list items.
   * It iterates over the items in the dropdown list, adds them to the map with their respective values,
   * and adds a click event listener to each item.
   */
  loadMap(dropdownList) {
    this.map = new Map();
    this.dataName = this.input.dataset.name;

    const items = dropdownList.querySelectorAll(".dropdown-list__item");
    
    for (let i = 0; i < items.length; i++) {
      this.map.set(items[i].dataset.value, items[i].textContent.replace(/\n/g, "").trim());
      this.addEventToItem(items[i]);
    }
  }

  /**
   * The addEventToItem method adds a click event listener to each dropdown item.
   * When an item is clicked, it calls the addItemToInput method with the clicked item as the argument.
   */
  addEventToItem(item) {
    item.addEventListener("click", (event) => {
      this.addItemToInput(event.target);
    });
  }

  /**
   * The addItemToInput method adds the selected item to the input field and updates the hidden input field if present.
   * It sets the value of the input field to the text content of the selected item, removes any line breaks and leading/trailing spaces.
   * It also sets the 'data-value' attribute of the input field to the value of the selected item.
   * If a hidden input field is present, it sets its value to the data value of the selected item.
   */
  addItemToInput(item) {
    this.input.value = item.textContent.replace(/\n/g, "").trim();
    this.input.dataset.value = item.dataset.value;
    this.dropdownList.classList.remove("active");

    const inputField  = this.input.parentElement;
    const hiddenInput = inputField.querySelector("[data-id='hidden-input']");
    
    if (hiddenInput) {
      hiddenInput.value = item.dataset.value;
    }
  }

  /**
   * The searchInput method handles the search functionality for the input field.
   * It filters the map based on the input value and updates the dropdown list accordingly.
   * If the input is empty, it shows all options. Otherwise, it filters the map entries
   * by checking if the entry value includes the input value (case-insensitive).
   */
  searchInput() {
    const inputValue = this.input.value.trim().toLowerCase();

    //If the input is empty, show all options
    if (inputValue == "") {
      this.updateDropdownList(Array.from(this.map.entries()));
      return;
    }

    //Filter the map
    const filteredItems = Array.from(this.map.entries()).filter((entry) => {
      if (entry[1].toLowerCase().includes(inputValue)) {
        return entry;
      }
    });

    //Update the filtered options in the select
    this.updateDropdownList(filteredItems);
  }

  /**
   * The updateDropdownList method updates the dropdown list with the filtered items.
   * It clears the existing options in the dropdown list and adds the filtered items as new options.
   * If no results are found, it adds a "No se encontraron resultados" option to the dropdown list.
   */
  updateDropdownList(filteredItems) {
    //Remove all options
    this.dropdownList.innerHTML = "";

    //Add the "No results found" option if there are no results
    if (filteredItems.length == 0) {
      const noResultsItem = document.createElement("div");
      noResultsItem.classList.add("dropdown-list__item--no-results");
      noResultsItem.textContent = "No se encontraron resultados";
      this.dropdownList.appendChild(noResultsItem);
      return;
    }

    for (let i = 0; i < filteredItems.length; i++) {
      const item = document.createElement("div");
      item.classList.add("dropdown-list__item");
      item.dataset.value = filteredItems[i][0];
      item.textContent = filteredItems[i][1];
      this.addEventToItem(item);
      this.dropdownList.appendChild(item);
    }
  }
}