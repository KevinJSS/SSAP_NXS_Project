import { Controller } from "@hotwired/stimulus"

// Clock Controller
// Connects to data-controller="clock"
export default class extends Controller {
  // The static targets attribute declares an array of targets defined in the HTML template that this controller will interact with.
  static targets = ['time'];

  // The connect method is called when the controller is connected to an element. It sets up the initial time display and schedules periodic updates.
  connect() {
    this.updateTime();
    setInterval(() => this.updateTime(), 1000);
  }

  // The updateTime method retrieves the current time and formats it. It then updates the clock display element with the formatted time.
  updateTime() {
    const clock = document.getElementById('clock');

    if (clock) {
      const currentTime = new Date();
      const hours = currentTime.getHours();
      const minutes = currentTime.getMinutes();
      const formattedTime = this.formatTime(hours, minutes);
      clock.textContent = formattedTime;
    }
  }

  // The formatTime method takes the hours and minutes as parameters and formats them into a 12-hour format with AM/PM indicator.
  formatTime(hours, minutes) {
    const amPm = hours >= 12 ? 'PM' : 'AM';
    const twelveHourFormat = hours % 12 || 12;
    const formattedHours = twelveHourFormat.toString().padStart(2, '0');
    const formattedMinutes = minutes.toString().padStart(2, '0');
    return `${formattedHours}:${formattedMinutes} ${amPm}`;
  }
}
