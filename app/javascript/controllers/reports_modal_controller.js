import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reports-modal"
export default class extends Controller {
  static targets = [ "reportSelect", "collaboratorSelect", "dates", "collaboratorReportType", "submitButton", "divider" ]

  connect() {
  }

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
