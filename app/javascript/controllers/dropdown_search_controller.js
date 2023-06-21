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
    if (!this.input.contains(event.target) && !this.select.contains(event.target)) {
      this.input.classList.remove("active");
      this.select.classList.remove("active");
      this.input.placeholder = "-- Selecciona una opción --";
    }
  }

  openDropdown(event) {
    //Set the input and select elements
    this.input = event.target;
    const parent = this.input.parentElement;
    this.select = parent.querySelector(".multiple-select");

    //Load the map if it doesn't exist or if the selected input has changed
    if (this.map == undefined || this.dataName != this.input.dataset.name) {
      this.loadMap(this.select);
    }

    //Add the active class to the select and input elements
    this.select.classList.add("active");
    this.input.classList.add("active");
    this.input.placeholder = "Buscar...";
  }

  loadMap(select) {
    //Create the map
    this.map = new Map();
    this.dataName = this.input.dataset.name;

    //Get the options from the select element
    const options = select.options;

    //Add the options to the map
    for (let i = 0; i < options.length; i++) {
      this.map.set(options[i].value, options[i].textContent.replace(/\n/g, "").trim());
      this.addEventToOption(options[i]);
    }
  }

  addEventToOption(option) {
    option.addEventListener("click", (event) => {
      this.addOptionToInput(event.target);
    });
  }

  addOptionToInput(option) {
    this.input.value = option.textContent.replace(/\n/g, "").trim();
    this.input.dataset.value = option.value;
    this.select.classList.remove("active");
  }

  searchInput() {
    const inputValue = this.input.value.trim().toLowerCase();

    //If the input is empty, show all options
    if (inputValue == "") {
      this.updateSelect(Array.from(this.map.entries()));
      return;
    }

    //Filter the map
    const filteredOptions = Array.from(this.map.entries()).filter((entry) => {
      if (entry[1].toLowerCase().includes(inputValue)) {
        return entry;
      }
    });

    //Update the filtered options in the select
    this.updateSelect(filteredOptions);
  }

  updateSelect(filteredOptions) {
    //Remove all options
    this.select.innerHTML = "";

    //Add the "No results found" option if there are no results
    if (filteredOptions.length == 0) {
      const option = document.createElement("option");
      option.value = "0";
      option.textContent = "No se encontraron resultados";
      this.select.appendChild(option);
      return;
    }

    for (let i = 0; i < filteredOptions.length; i++) {
      const optionElement = document.createElement("option");
      optionElement.value = filteredOptions[i][0];
      optionElement.textContent = filteredOptions[i][1];
      this.addEventToOption(optionElement);
      this.select.appendChild(optionElement);
    }
  }
}