class AddNameToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :name, :string
  end
end
