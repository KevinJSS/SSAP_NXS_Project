import NestedForm from 'stimulus-rails-nested-form'

export default class extends NestedForm {
  connect() {
    super.connect();
    this.checkEmptyTable();
    if (this.element.dataset.formModel == "activities") this.showTotalHours();
  }

  addPhase(event) {
    super.add(event);
    const lastWrapper = this.addSelectedOption(); //add selected option to nested form

    //Get modal hours input and form nested input
    const modalHours = document.getElementById("phaseHours");

    if (modalHours.value == "") {
      alert("Indique las horas realizadas de la actividad seleccionada");
      if (lastWrapper) this.hide(lastWrapper.querySelector(".btn-danger"));
      return;
    }

    //Set modal hours value to form nested input
    const inputHours = lastWrapper.querySelector(".nested-input-hours");
    inputHours.value = modalHours.value;

    //Clear modal input
    modalHours.value = "";

    //Update total hours
    this.updatedTotalHours(lastWrapper, "add");
  }

  addUser(event) {
    super.add(event);
    this.addSelectedOption();
  }

  addSelectedOption() {
    const wrappers = document.querySelectorAll('.nested-form-wrapper');
    const lastWrapper = wrappers[wrappers.length - 1];

    //Get modal input and form nested input
    const modalInput=document.getElementById("modalInput");
    const hiddenInput=lastWrapper.querySelector("input[type*=hidden]");
    const inputText=lastWrapper.querySelector(".nested-input-text");

    if (modalInput.dataset.value == "") {
      alert("Seleccione una opción");
      this.hide(lastWrapper.querySelector(".btn-danger"));
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

  updatedTotalHours(wrapper, action) {
    const totalHours = document.getElementById("totalHours");
    const inputHours = wrapper.querySelector(".nested-input-hours");
    if (totalHours.value == "") totalHours.value = 0;
    totalHours.value = action == "add" ? parseFloat(totalHours.value) + parseFloat(inputHours.value) : parseFloat(totalHours.value) - parseFloat(inputHours.value);
  }

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
