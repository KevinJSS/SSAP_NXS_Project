import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["link"];

  connect() {
    this.setActiveLink();
    window.addEventListener("resize", this.onResize.bind(this));
  }

  onResize() {
    this.setActiveLink();
  }

  setActiveLink() {
    const activeLinkId = sessionStorage.getItem("activeLinkId");
    if (activeLinkId) {
      this.linkTargets.forEach((link) => {
        link.classList.remove("active");
        link.parentElement.classList.remove("active");
      });

      const activeLink = this.linkTargets.find((link) => link.dataset.linkId === activeLinkId);
      if (activeLink) {
        activeLink.parentElement.classList.add("active");
        activeLink.classList.add("active");
      }
    }
  }

  onClick(event) {
    this.linkTargets.forEach((link) => {
      link.parentElement.classList.remove("active");
      link.classList.remove("active");
    });

    const clickedLink = event.currentTarget;
    const activeLinkId = clickedLink.dataset.linkId;
    sessionStorage.setItem("activeLinkId", activeLinkId);
  }

  removeActiveLink(event) {
    sessionStorage.removeItem("activeLinkId");
  }
}
