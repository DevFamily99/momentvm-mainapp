class CreateJoinTableRolesUser < ActiveRecord::Migration[5.2]
  def change
    create_join_table :roles, :users do |t|
       t.integer :role_id
       t.integer :user_id
    end
  end
end
