require "test_helper"

class PromptTemplateTest < ActiveSupport::TestCase
  def setup
    @prompt_template = PromptTemplate.new(name: "Csv template", task: "Do this", format: "This is a format we should follow.")
  end

  test "is valid" do
    assert @prompt_template.valid?
  end

  test "name should be present" do
    @prompt_template.name = ""
    assert_not @prompt_template.valid?
  end

  test "task should be present" do
    @prompt_template.task = ""
    assert_not @prompt_template.valid?
  end

  test "format should be present" do
    @prompt_template.format = ""
    assert_not @prompt_template.valid?
  end
end
