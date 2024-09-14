class CreateRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :records do |t|
      t.string :Record
      t.text :short_summary
      t.text :full_summary

      t.timestamps
    end
  end
end
