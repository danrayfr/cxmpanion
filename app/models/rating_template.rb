class RatingTemplate < ApplicationRecord
  has_rich_text :remarks
  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(created_at: :desc) }
end
