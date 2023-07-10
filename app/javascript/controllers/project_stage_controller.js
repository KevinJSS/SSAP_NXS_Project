import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="project-stage"
export default class extends Controller {
  static targets = [ "stage", "status" ]

  connect() {
    this.toggleStage({ currentTarget: this.stageTarget }) 
  }

  toggleStage(event) {
    const select = event.currentTarget
    const stage = select.options[select.selectedIndex].value
    if (stage == "finished") {
      const status = this.statusTarget.options[this.statusTarget.selectedIndex]
      status.text = "Entregado";
      this.statusTarget.disabled = true; 
      return;
    }
    if (this.statusTarget.disabled == true) this.statusTarget.disabled = false;
  }
}
