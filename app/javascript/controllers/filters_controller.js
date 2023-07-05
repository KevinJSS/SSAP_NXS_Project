import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filters"
export default class extends Controller {
  connect() {
    this.showFiltersButton();
    this.toggle();
  }

  clearFilters(event) {
    const currentURL = window.location.href;
    const index = currentURL.indexOf('?q');

    if (index !== -1) {
      const newURL = currentURL.substring(0, index);
      window.location.href = newURL;
      //sessionStorage.setItem('filtersContentState', 'closed');
    }
  }

  showFiltersButton() {
    const filtersButton = document.querySelector('#clear-filters-button');
    const currentURL = window.location.href;
    const index = currentURL.indexOf('?q');
    if (index != -1) filtersButton.style.display = 'block';
  }

  toggle(event) {
    const filtersContentState = sessionStorage.getItem('filtersContentState');
    
    const toggle = document.querySelector('#toggle');
    const filtersContent = document.querySelector('.filters__content');
    
    if (filtersContentState === 'closed' || filtersContentState === null) {
      sessionStorage.setItem('filtersContentState', 'open');
      toggle.innerHTML = '<i class="bi bi-caret-up-fill"></i>';
      filtersContent.style.display = 'block';
    } else {
      sessionStorage.setItem('filtersContentState', 'closed');
      toggle.innerHTML = '<i class="bi bi-caret-down-fill"></i>';
      filtersContent.style.display = 'none';
    }
  }
}
