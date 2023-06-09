class AddClientToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :encrypted_client_id, :string
    add_column :teams, :encrypted_client_secret, :string
  end
end