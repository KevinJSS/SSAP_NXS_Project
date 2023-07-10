import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown-search"
export default class extends Controller {
  connect() {
    document.addEventListener("click", this.handleClick);
  }

  disconnect() {
    document.removeEventListener("click", this.handleClick);
  }

  handleClick = (event) => {
    if (this.input === undefined ) return;

    //If the click is outside the input and select elements, remove the active class
    if (!this.input.contains(event.target) && !this.dropdownList.contains(event.target)) {
      this.input.classList.remove("active");
      this.dropdownList.classList.remove("active");
      this.input.placeholder = "- Selecciona una opción -";
    }
  }

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

  loadMap(dropdownList) {
    this.map = new Map();
    this.dataName = this.input.dataset.name;

    const items = dropdownList.querySelectorAll(".dropdown-list__item");
    
    for (let i = 0; i < items.length; i++) {
      this.map.set(items[i].dataset.value, items[i].textContent.replace(/\n/g, "").trim());
      this.addEventToItem(items[i]);
    }
  }

  addEventToItem(item) {
    item.addEventListener("click", (event) => {
      this.addItemToInput(event.target);
    });
  }

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

  updateDropdownList(filteredItems) {
    //Remove all options
    this.dropdownList.innerHTML = "";

    //Add the "No results found" option if there are no results
    if (filteredItems.length == 0) {
      const noResultsItem = document.createElement("div");
      noResultsItem.classList.add("dropdown-list__item");
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