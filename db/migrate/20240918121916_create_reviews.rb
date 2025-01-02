class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.string :name
      t.string :assignee, null: false
      t.references :record, null: false, foreign_key: true

      t.timestamps
    end
  end
end
