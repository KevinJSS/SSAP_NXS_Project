import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navigation"
export default class extends Controller {
  connect() {
  }

  goBack() {
    window.history.back()
  }
}
