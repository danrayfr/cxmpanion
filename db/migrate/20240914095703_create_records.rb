class CreateRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :records do |t|
      t.string :uid, null: false

      t.timestamps
    end
  end
end
