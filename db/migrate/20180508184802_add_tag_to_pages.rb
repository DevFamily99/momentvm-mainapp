class AddTagToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :tag, :string
  end
end
