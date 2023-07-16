import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="project-stage"
export default class extends Controller {
  static targets = [ "stage", "status" ]

  /**
   * The connect method is called when the controller is connected to an element.
   * It triggers the toggleStage method to handle the initial state of the stage and status elements.
   */
  connect() {
    this.toggleStage() 
  }

  /**
   * The toggleStage method handles the state of the stage and status elements based on the selected stage value.
   * It retrieves the selected stage value from the stage element.
   * If the stage value is "finished", it updates the text of the status element to "Entregado" (Delivered),
   * disables the status element, and returns.
   * If the status element is already disabled, it enables it.
   */
  toggleStage() {
    const select = this.stageTarget
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
