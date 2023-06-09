class CreateTemplateSchemas < ActiveRecord::Migration[5.1]
  def change
    create_table :template_schemas do |t|
      t.text :body
      t.references :template, foreign_key: true

      t.timestamps
    end
  end
end
