import NestedForm from 'stimulus-rails-nested-form'

export default class extends NestedForm {
  connect() {
    super.connect()
  }

  add(event) {
    super.add(event)
    this.addNestedForm();
  }

  addNestedForm() {
    //Get last wrapper
    const wrappers = document.querySelectorAll('.nested-form-wrapper');
    const lastWrapper = wrappers[wrappers.length - 1];

    //Get modal input and form nested input
    const modalInput=document.getElementById("modalInput");
    const hiddenInput=lastWrapper.querySelector("input[type*=hidden]");
    const inputName=lastWrapper.querySelector(".nested-input-name");

    //Set modal input value to form nested input
    hiddenInput.value = modalInput.dataset.value;
    inputName.value = modalInput.value;

    //Clear modal input
    modalInput.value = "";
  }

  hide(event) {
    parent = event.target.parentElement;
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

      if (event.target.dataset.formModel == "activities") this.updatedTotalHours(wrapper);
    }
  }

  updatedTotalHours(wrapper) {
    alert("updated total hours");
  }
}
