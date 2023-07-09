import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filters"
export default class extends Controller {
  connect() {
    this.showFiltersButton();
    this.fixedFiltersContent();
  }

  clearFilters(event) {
    const currentURL = window.location.href;
    const index = currentURL.indexOf('?');

    console.log(currentURL);
    console.log(index);

    if (index !== -1) {
      const newURL = currentURL.substring(0, index);
      window.location.href = newURL;
    }
  }

  showFiltersButton() {
    const filtersButton = document.querySelector('#clear-filters-button');
    const currentURL = window.location.href;
    const index = currentURL.indexOf('?');
    if (index != -1) filtersButton.style.display = 'block';
  }

  toggle(event) {
    const toggle = event.currentTarget.querySelector('#toggle');
    const filtersContent = document.querySelector('.filters__content');
    
    if (toggle.innerHTML == '<i class="bi bi-caret-down-fill"></i>') {
      toggle.innerHTML = '<i class="bi bi-caret-up-fill"></i>';
      filtersContent.style.display = 'block';
      sessionStorage.setItem(`filterState-${toggle.dataset.name}`, 'opened');
      return;
    }
    toggle.innerHTML = '<i class="bi bi-caret-down-fill"></i>';
    filtersContent.style.display = 'none';
    sessionStorage.setItem(`filterState-${toggle.dataset.name}`, 'closed');
  }

  fixedFiltersContent() {
    const toggle = document.querySelector('#toggle');

    const filtersContentState = sessionStorage.getItem(`filterState-${toggle.dataset.name}`);
    const filtersContent = document.querySelector('.filters__content');

    if (filtersContentState === `opened`) {
      toggle.innerHTML = '<i class="bi bi-caret-up-fill"></i>';
      filtersContent.style.display = 'block';
    }
  }
}
