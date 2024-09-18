import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="prompt"
export default class extends Controller {
  static targets = [ "templateSelect", "task", "format"]

  connect() {
    if (!isEditing) {
      this.updateForm()
    }
  }

  updateForm() {
    const selectedTemplate = this.templateSelectTarget.value;
    const baseUrl = window.location.origin;

    const isEditing = window.isEditing; // Check if @coaching.persisted?

    if (selectedTemplate) {
      fetch(`${baseUrl}/prompt_templates/${selectedTemplate}.json`)
      .then((response) => response.json())
      .then((data) => {
        // Populate data to the targets
        this.taskTarget.value = data.task
        this.formatTarget.value = data.format.body
      })
    } else {
      this.taskTarget.value = ""
      this.formatTarget.value = ""
    }
  }
}
