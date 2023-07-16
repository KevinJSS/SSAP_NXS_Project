import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reports-modal"
export default class extends Controller {
  static targets = [ "reportSelect", "collaboratorSelect", "dates", "collaboratorReportType", "submitButton", "divider" ]

  connect() {
  }

  /**
   * The toggleForm method is called when the reportSelect value changes.
   * It toggles the visibility of the form elements based on the selected report type.
   * If the report type is "collaborator", it shows the collaboratorReportType and collaboratorSelect elements.
   * If the report type is not "collaborator", it hides the collaboratorReportType and collaboratorSelect elements.
   * It also toggles the visibility of the submitButton, dates, and divider elements based on whether a report type is selected or not.
   */
  toggleForm() {
    const reportType = this.reportSelectTarget.value;

    this.submitButtonTarget.classList.toggle("show", reportType !== "");
    this.datesTarget.classList.toggle("show", reportType !== "");
    this.dividerTarget.classList.toggle("show", reportType !== "");

    if (reportType === "collaborator") {
      this.collaboratorReportTypeTarget.classList.add("show");
      this.collaboratorSelectTarget.classList.add("show");
    } else {
      this.collaboratorReportTypeTarget.classList.remove("show");
      this.collaboratorSelectTarget.classList.remove("show");
    }
  }

  /**
   * The submit method is called when the form is submitted.
   * It submits the form by calling the submit() method on the generateForm element.
   * After submitting the form, it resets the reportSelect, collaborator, start_date, and end_date values,
   * and toggles the form elements to their initial state.
   */
  submit() {
    const generateForm = document.getElementById("generate-form");
    generateForm.submit();

    const collaborator = document.getElementById("collaborator");
    const start_date = document.getElementById("start_date");
    const end_date = document.getElementById("end_date");

    this.reportSelectTarget.value = "";
    collaborator.value = "";
    start_date.value = "";
    end_date.value = "";
    this.toggleForm();
  }  
}
