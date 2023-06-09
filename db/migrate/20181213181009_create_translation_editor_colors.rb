class CreateTranslationEditorColors < ActiveRecord::Migration[5.2]
  def change
    create_table :translation_editor_colors do |t|
      t.string :name
      t.string :hex
      t.timestamps
    end
  end
end
