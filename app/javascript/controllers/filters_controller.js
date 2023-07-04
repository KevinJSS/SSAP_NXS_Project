import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filters"
export default class extends Controller {
  connect() {
  }

  toggle(event) {
    const toggle = event.currentTarget.querySelector('#toggle');
    
    if (toggle.innerHTML == '<i class="bi bi-caret-down-fill"></i>') {
      toggle.innerHTML = '<i class="bi bi-caret-up-fill"></i>';
      return;
    }
    toggle.innerHTML = '<i class="bi bi-caret-down-fill"></i>';
  }
}
