import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["link", "subtitle"];

  /**
   * The connect method is called when the controller is connected.
   * It sets the active link based on the current view and adds a resize event listener to trigger the setActiveLink method.
   */
  connect() {
    this.setActiveLink();
    window.addEventListener("resize", this.onResize.bind(this));
  }

  /**
   * The onResize method is called when the window is resized.
   * It triggers the setActiveLink method to update the active link based on the current view.
   */
  onResize() {
    this.setActiveLink();
  }

   /**
   * The setActiveLink method updates the active link in the sidebar based on the current view.
   * It removes the "active" class from all link elements and their parent elements.
   * Then it finds the active section based on the data-section-id attribute of the subtitle elements,
   * and the active link based on the data-link-id attribute of the link elements.
   * If an active link is found, it adds the "active" class to its parent element and the link element.
   * If an active section is found, it adds the "active" class to the section element.
   */
  setActiveLink() {
    const main = document.querySelector("main");

    if (main) {
      const dataViewId = main.dataset.viewId;

      if (!dataViewId) return;

      this.linkTargets.forEach((link) => {
        link.classList.remove("active");
        link.parentElement.classList.remove("active");
      });

      const activeSection = this.subtitleTargets.find((subtitle) => subtitle.dataset.sectionId === dataViewId);
      const activeLink = this.linkTargets.find((link) => link.dataset.linkId === dataViewId);

      if (activeLink) {
        activeLink.parentElement.classList.add("active");
        activeLink.classList.add("active");

      } else if (activeSection) {
        activeSection.classList.add("active");
      }
    }
  }
}
