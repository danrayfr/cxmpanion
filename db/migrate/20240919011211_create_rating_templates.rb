class CreateRatingTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :rating_templates do |t|
      t.string :name, null: false
      t.json :metrics, default: []

      t.timestamps
    end
  end
end
