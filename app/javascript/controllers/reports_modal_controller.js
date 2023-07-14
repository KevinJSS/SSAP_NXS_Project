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
    var generateForm = document.getElementById("generate-form");
    generateForm.submit();
    // setTimeout(function() {
    //   location.reload();
    // }, 2000);
  }  
}
