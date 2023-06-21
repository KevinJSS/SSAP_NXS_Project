import NestedForm from 'stimulus-rails-nested-form'

export default class extends NestedForm {
  connect() {
    super.connect()
  }

  hide(event) {
    parent = event.target.parentElement;
    const wrapper = parent.type == "button" ? parent.parentElement : parent;

    if (wrapper) {
      wrapper.style.display = "none";
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
