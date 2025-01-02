import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="rating-form"
export default class extends Controller {
  static targets = [
    "templateSelect", "metricCheckboxes", "checkboxes",
    "score", "metricForms", "noteField" ];

  connect() {
    this.updateForm();
    this.calculateScore();
  }

  updateForm() {
    const selectedTemplateId = this.templateSelectTarget.value;
    const score = this.scoreTarget;
    const baseUrl = window.location.origin;

    const editing = window.isEditing;

    if (selectedTemplateId) {
      // Make an AJAX request to fetch the selected qa template data.
      fetch(`${baseUrl}/rating_templates/${selectedTemplateId}.json`)
      .then((response) => response.json())
      .then((data) => {

        this.metricCheckboxesTarget.innerHTML = ""
        score.value = 100

        if (!editing) {
          this.noteFieldTarget.value = data.remarks.body
        }

        // Generate checkboxes for each metric in the qa_template
        data.metrics.forEach((metric) => {
          const checkBoxHtml = `
            <div class="mb-6 inline-flex">
              <label class="block">
                <input type="checkbox" name="quality[metric_ids][]" value="${metric.deduction}" data-action="change->rating-form#updateScore" rating-form-target="checkboxes" data-description="${metric.description}" data-name="${metric.metric_name}">
                ${metric.metric_name}
              </label>
            </div>
          `;
          this.metricCheckboxesTarget.insertAdjacentHTML("beforeend", checkBoxHtml);
        });
      });
    } else {
      this.noteFieldTarget.value = '';
      this.metricCheckboxesTarget.innerHTML = '';
    }
  }

  calculateScore() {
    const metricCheckboxesElement = this.metricCheckboxesTarget; // Get the parent element
    const checkboxes = metricCheckboxesElement.querySelectorAll('input[type="checkbox"]'); // Get all child checkboxes
    const score = this.scoreTarget;
    const selectedDescriptions = []; // Initialize an array to store selected descriptions

    // let selectedDescriptions = []; // Create an array to store selected descriptions

    if (checkboxes) {
      let rating = 100; // Initialize with the base score

      checkboxes.forEach((checkbox) => {
        if (checkbox.checked) {
          // Subtract the checkbox value from the score if it's checked
          const checkboxValue = parseInt(checkbox.value)
          rating -= checkboxValue;

          // Append the description to the newNoteValue
          const metricDescription = checkbox.dataset.description;
          if (metricDescription) {
            selectedDescriptions.push(metricDescription);
          }

        }
      });

      if (score) {
        score.value = rating;
      }

      const newNoteValue = selectedDescriptions.join('\n');

      // Concatenate the selected descriptions with the existing value of noteFieldTarget
      const existingNoteValue = this.noteFieldTarget.value;

      // this.noteFieldTarget.value = existingNoteValue + (existingNoteValue ? '\n\n' : '') + `<div class="mb-6"><p>${newNoteValue}</p></div`;

      // this.noteFieldTarget.value =
      // `<div class="mb-6"><p>${newNoteValue}</p></div><br/>` + (newNoteValue ? '\n\n' : '') + existingNoteValue;
    }
  }

  updateScore(event) {
    this.calculateScore();

    // Check if any checkbox is checked
    const checkboxes = this.metricCheckboxesTarget.querySelectorAll('input[type="checkbox"]');

    // Clear the metric forms container
    this.metricFormsTarget.innerHTML = '';

    checkboxes.forEach((checkbox) => {
    if (checkbox.checked) {
        // Get the data specific to the checked checkbox (you can customize this part)
        const metricName = checkbox.getAttribute('data-name');;
        const metricDeduction = checkbox.value;
        const metricContent = checkbox.getAttribute('data-description');

        // Create a nested form for the checked checkbox
        const nestedFormHtml = `
        <div class="nested-form-wrapper">
          <div>
            <label class="block text-sm font-medium text-graphite">
              Metrics
            </label>
            <!-- Add your nested form HTML here -->
            <div class="mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6 px-6 pb-6 border-2 border-[#303e7b] border-dashed rounded-md">
              <!-- Populate the form fields with data specific to the checkbox -->
              <div class="sm:col-span-3 mt-3">
                <label class="text-indigo mb-3">Name</label>
                <input type="text" name="metric_name[]" value="${metricName}" class="js-start-time w-full rounded-md border border-[#e0e0e0] bg-white py-3 px-6 text-base font-medium text-[#6B7280] outline-none focus:border-[#6A64F1] focus:shadow-md" readonly="true" />
              </div>

              <div class="sm:col-span-3 mt-3">
                <label class="text-indigo mb-3">Deduction</label>
                <input type="number" name="deduction[]" value="${metricDeduction}" class="js-start-time w-full rounded-md border border-[#e0e0e0] bg-white py-3 px-6 text-base font-medium text-[#6B7280] outline-none focus:border-[#6A64F1] focus:shadow-md" readonly="true" />
              </div>

              <!-- Add other form fields as needed -->

              <div class="col-span-full">
                <label class="text-indigo mb-3">Content</label>
                <textarea class="w-full rounded-lg border-gray-200 p-3 text-sm" placeholder="Enter custom content here..." rows="8" id="message" name="content[]">${metricContent}</textarea>
              </div>

              <div class="">
                <button type="button" class="bg-[#303e7b] rounded-md px-5 py-3 text-white hover:bg-indigo-300 w-52 cursor-pointer rounded-md p-2 inline-flex items-center justify-center text-white hover:text-white hover:bg-graphite focus:outline-none focus:ring-2 focus:ring-inset focus:ring-stone" data-action="nested-form#remove">
                  <span class="sr-only">Close menu</span>
                  <!-- Heroicon name: outline/x -->
                  <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                  <span class="ml-4">Remove</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      `;

      // Append the nested form to the metricFormsTarget
      this.metricFormsTarget.insertAdjacentHTML("beforeend", nestedFormHtml);
    }
    });
  }
}
