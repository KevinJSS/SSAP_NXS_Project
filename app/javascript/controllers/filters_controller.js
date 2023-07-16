import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filters"
export default class extends Controller {
  /**
   * The connect method is called when the controller is connected to an element.
   * It triggers the showFiltersButton and fixedFiltersContent methods.
   */
  connect() {
    this.showFiltersButton();
    this.fixedFiltersContent();
  }

  /**
   * The clearFilters method is called when the "clear filters" event is triggered.
   * It retrieves the current URL and removes the query string by extracting the URL before the '?' character.
   * The page is then redirected to the new URL without the query string.
   */
  clearFilters(event) {
    const currentURL = window.location.href;
    const index = currentURL.indexOf('?');

    if (index !== -1) {
      const newURL = currentURL.substring(0, index);
      window.location.href = newURL;
    }
  }

  /**
   * The showFiltersButton method displays the "clear filters" button if the query string is present in the URL.
   * It retrieves the current URL and checks if it contains the query parameter 'q%'.
   * If the query parameter is present, the button's display style is set to 'block' to make it visible.
   */
  showFiltersButton() {
    const filtersButton = document.querySelector('#clear-filters-button');
    const currentURL = window.location.href;
    const query = currentURL.indexOf('q%');
    if (query != -1) filtersButton.style.display = 'block';
  }

  /**
   * The toggle method is called when the toggle event is triggered.
   * It toggles the visibility of the filters content based on the state of the toggle element.
   * If the toggle element's HTML content is the caret-down icon, it changes it to the caret-up icon,
   * displays the filters content, and stores the 'opened' state in the session storage.
   * If the toggle element's HTML content is the caret-up icon, it changes it to the caret-down icon,
   * hides the filters content, and stores the 'closed' state in the session storage.
   */
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

  /**
   * The fixedFiltersContent method ensures the correct state of the filters content on page load.
   * It retrieves the stored filters content state from the session storage based on the toggle element's dataset name.
   * If the state is 'opened', it sets the toggle icon to the caret-up icon and displays the filters content.
   */
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
