require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  def setup
    @record = records(:one)
    @review = @record.reviews.build(assignee: "reviewee", remarks: "hello world")
  end

  test "is review valid" do
    assert @review.valid?
  end

  test "remarks should be present" do
    @review.remarks = ""
    assert_not @review.valid?
  end
end
