require "test_helper"

class RatingTest < ActiveSupport::TestCase
  def setup
    @record = records(:one)
    @rating = @record.build_rating(score: 99)
  end

  test "should be valid" do
    assert @rating.valid?
  end

  test "rating should be greater than or equal to 0" do
    @rating.score = -1
    assert_not @rating.valid?

    @rating.score = 0
    assert @rating.valid?
  end

  test "rating should be less than or equal to 100" do
    @rating.score = 101
    assert_not @rating.valid?

    @rating.score = 100
    assert @rating.valid?
  end
end
