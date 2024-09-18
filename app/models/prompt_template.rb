class PromptTemplate < ApplicationRecord
  has_rich_text :format
  validates_presence_of :task, :format
end
