class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.string :owner_firstname
      t.string :owner_lastname
      t.string :owner_email
      t.string :company
      t.string :preview_url
      t.string :webdav_name
      t.string :webdav_password
      t.boolean :approved
    end
  end
end
