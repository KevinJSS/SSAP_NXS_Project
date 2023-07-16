import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navigation"
export default class extends Controller {
  connect() {
  }

  // Called when the "back" button is clicked
  // So we can go back in the browser history
  goBack() {
    window.history.back()
  }
}
