class AddTranslationProjectIdToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :translation_project_id, :string
  end
end
