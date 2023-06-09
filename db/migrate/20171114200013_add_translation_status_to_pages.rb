class AddTranslationStatusToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :translation_status, :integer
  end
end
