class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.timestamps
      t.string :name
      t.text :body
    end
  end
end