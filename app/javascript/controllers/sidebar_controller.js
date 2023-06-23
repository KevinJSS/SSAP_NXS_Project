import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["link", "subtitle"];

  connect() {
    this.setActiveLink();
    window.addEventListener("resize", this.onResize.bind(this));
  }

  onResize() {
    this.setActiveLink();
  }

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
