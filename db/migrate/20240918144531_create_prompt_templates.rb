class CreatePromptTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :prompt_templates do |t|
      t.string :name, null: false
      t.text :task, null: false

      t.timestamps
    end
  end
end
