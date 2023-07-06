import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clock"
export default class extends Controller {
  static targets = ['time'];

  connect() {
    this.updateTime();
    setInterval(() => this.updateTime(), 1000);
  }

  updateTime() {
    const currentTime = new Date();
    const hours = currentTime.getHours();
    const minutes = currentTime.getMinutes();
    const formattedTime = this.formatTime(hours, minutes);
    this.timeTarget.textContent = formattedTime;
  }

  formatTime(hours, minutes) {
    const amPm = hours >= 12 ? 'PM' : 'AM';
    const twelveHourFormat = hours % 12 || 12;
    const formattedHours = twelveHourFormat.toString().padStart(2, '0');
    const formattedMinutes = minutes.toString().padStart(2, '0');
    return `${formattedHours}:${formattedMinutes} ${amPm}`;
  }
}
