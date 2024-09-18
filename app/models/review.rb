class Review < ApplicationRecord
  belongs_to :record
  has_rich_text :remarks

  validates_presence_of :remarks, :assignee
  before_create :one_reviewee_per_record, if: -> { assignee == "reviewee" }

  private

  def one_reviewee_per_record
    if record.reviews.reviewee.exists?
      errors.add(:assignee, "There can only be one reviewee per record")
    end
  end

  def self.reviewee
    where(assignee: "reviewee")
  end

  def self.reviewer
    where(assignee: "reviewer")
  end
end
