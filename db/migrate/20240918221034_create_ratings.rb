class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.integer :score
      t.json :metrics
      t.references :record, null: false, foreign_key: true

      t.timestamps
    end
  end
end
