class PromptTemplate < ApplicationRecord
  has_rich_text :format
  validates_presence_of :name, :task, :format

  scope :ordered, -> { order(created_at: :desc) }
end
