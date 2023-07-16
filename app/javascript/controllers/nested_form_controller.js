import NestedForm from 'stimulus-rails-nested-form'

/**
 * This controller extends the NestedForm controller provided by the 'stimulus-rails-nested-form' package.
 * It adds additional functionality to handle nested forms and perform specific actions when adding or removing elements.
 */
export default class extends NestedForm {
  /**
   * The connect method is called when the controller is connected to an element.
   * It performs initialization tasks after the controller is connected.
   * In this case, it checks if the connected element represents a form for activities and shows the total hours.
   */
  connect() {
    super.connect();
    this.checkEmptyTable();
    if (this.element.dataset.formModel == "activities") this.showTotalHours();
  }

  /**
   * The addPhase method is called when a new phase is added.
   * It extends the base add method from the parent controller to handle additional logic specific to phases.
   * It retrieves the value of the modal hours input and sets it as the value of the nested form input for hours.
   * It also updates the total hours based on the added phase.
   */
  addPhase(event) {
    super.add(event);
    const lastWrapper = this.addSelectedOption(); //add selected option to nested form

    //Get modal hours input and form nested input
    const modalHours = document.getElementById("phaseHours");

    if (modalHours.value == "") {
      alert("Indique las horas realizadas de la actividad seleccionada");
      if (lastWrapper) this.hide(lastWrapper.querySelector(".text-danger"));
      return;
    }

    //Set modal hours value to form nested input
    const inputHours = lastWrapper.querySelector(".nested-input-hours");
    inputHours.value = Math.abs(modalHours.value);

    //Clear modal input
    modalHours.value = "";

    //Update total hours
    this.updatedTotalHours(lastWrapper, "add");
  }

  /**
   * The addUser method is called when a new user is added.
   * It extends the base add method from the parent controller to handle additional logic specific to users.
   * It adds the selected option to the nested form, which sets the value and text of the corresponding inputs.
   */
  addUser(event) {
    super.add(event);
    this.addSelectedOption();
  }

  /**
   * The addSelectedOption method adds the selected option from the modal to the nested form.
   * It retrieves the value and text of the modal input and sets them as the value and text of the nested form inputs.
   * It also handles the case when no option is selected and displays an alert message.
   * It returns the last added wrapper element for further manipulation if needed.
   */
  addSelectedOption() {
    const wrappers = document.querySelectorAll('.nested-form-wrapper');
    const lastWrapper = wrappers[wrappers.length - 1];

    //Get modal input and form nested input
    const modalInput=document.getElementById("modalInput");
    const hiddenInput=lastWrapper.querySelector("input[type*=hidden]");
    const inputText=lastWrapper.querySelector(".nested-input-text");

    if (modalInput.dataset.value == "") {
      alert("Seleccione una opción");
      this.hide(lastWrapper.querySelector(".text-danger"));
      return;
    }

    //remove empty message
    this.checkEmptyTable();

    //Set modal input value to form nested input
    hiddenInput.value = modalInput.dataset.value;
    inputText.value = modalInput.value;

    //Clear modal input
    modalInput.value = "";
    modalInput.dataset.value = "";

    //return lastWrapper
    return lastWrapper;
  }

  /**
   * The hide method hides a wrapper element, typically used when removing an element.
   * It hides the wrapper element, sets the '_destroy' input value to '1' to indicate it should be destroyed upon form submission.
   * It also hides all children elements of the wrapper.
   * If the form model is 'activities', it also updates the total hours by calling the updatedTotalHours method.
   * Finally, it checks if the table is empty to show the empty message if needed.
   */
  hide(event) {
    parent = event.type == 'click' ? event.target.parentElement : event;
    const wrapper = parent.type == "button" ? parent.parentElement : parent;

    if (wrapper) {
      wrapper.style.display = "none";
      wrapper.classList.remove("py-3");
      wrapper.classList.remove("border-bottom");
      wrapper.querySelector("input[name*=_destroy]").value = "1";

      //hide children elements
      const children = wrapper.querySelectorAll('*');
      children.forEach(child => {
        child.style.display = 'none';
      });

      if (wrapper.dataset.formModel == "activities") this.updatedTotalHours(wrapper, "hide");

      this.checkEmptyTable(); //check if table is empty to show empty message
    }
  }

  /**
   * The updatedTotalHours method updates the total hours value based on the action performed (add or remove).
   * It retrieves the input hours value from the provided wrapper element and updates the total hours accordingly.
   */
  updatedTotalHours(wrapper, action) {
    const totalHours = document.getElementById("totalHours");
    const inputHours = wrapper.querySelector(".nested-input-hours");
    if (totalHours.value == "") totalHours.value = 0;
    totalHours.value = action == "add" ? parseFloat(totalHours.value) + parseFloat(inputHours.value) : parseFloat(totalHours.value) - parseFloat(inputHours.value);
  }

  /**
   * The showTotalHours method calculates and shows the total hours for the activities form.
   * It iterates through each wrapper element and retrieves the input hours value to update the total hours.
   */
  showTotalHours() {
    const wrappers = document.querySelectorAll('.nested-form-wrapper');

    for (let i = 0; i < wrappers.length; i++) {
      const wrapper = wrappers[i];
      const inputHours = wrapper.querySelector(".nested-input-hours");
      const totalHours = document.getElementById("totalHours");
      if (totalHours.value == "") totalHours.value = 0;
      totalHours.value = parseFloat(totalHours.value) + parseFloat(inputHours.value);
    }
  }

  /**
   * The checkEmptyTable method checks if the table is empty and shows/hides the empty message accordingly.
   * It iterates through each wrapper element and checks if the '_destroy' input value is 'false'.
   * If all elements have the '_destroy' value set to 'true', it shows the empty message, otherwise it hides it.
   */
  checkEmptyTable() {
    const wrappers = document.querySelectorAll('.nested-form-wrapper');
    let empty = true;
    wrappers.forEach(wrapper => {
      if (wrapper.querySelector("input[name*=_destroy]").value == "false") empty = false;
    });

    const emptyMessage = document.getElementById("emptyMessage");

    if (empty) {
      emptyMessage.style.display = "block";
    } else {
      emptyMessage.style.display = emptyMessage.style.display == "block" || emptyMessage.style.display == "" ? "none" : emptyMessage.style.display;
    }
  }
}
