# This was automatically created by
# rails generate sorcery:install remember_me reset_password
class SorceryCore < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email,            :null => false
      t.string :crypted_password
      t.string :salt

      # Custom fields
      t.string :name
      # Field for Demandware publishing
      t.string :language # For default language view
      t.string :region # For site group?

      t.timestamps                :null => false
    end

    add_index :users, :email, unique: true
  end
end
