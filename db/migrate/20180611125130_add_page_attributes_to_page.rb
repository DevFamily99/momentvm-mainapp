class AddPageAttributesToPage < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :title, :integer
    add_column :pages, :description, :integer
    add_column :pages, :keywords, :integer
    add_column :pages, :url, :integer
  end
end
