class AddRolesToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :roles, :text
  end
end
