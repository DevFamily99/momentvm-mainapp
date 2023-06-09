class AddCategoryToPage < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :category, :string
  end
end
