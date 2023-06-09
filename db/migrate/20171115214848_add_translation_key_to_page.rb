class AddTranslationKeyToPage < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :translation_key, :string
  end
end
