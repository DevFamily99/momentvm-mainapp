class CreateTemplateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :template_tags do |t|
      t.references :template, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
