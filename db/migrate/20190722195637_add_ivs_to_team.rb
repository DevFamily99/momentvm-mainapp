class AddIvsToTeam < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :encrypted_client_id_iv, :string
    add_column :teams, :encrypted_client_secret_iv, :string
  end
end
