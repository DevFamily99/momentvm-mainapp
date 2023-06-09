class RemoveWebDavFromTeams < ActiveRecord::Migration[5.2]
  def change
    remove_column :teams, :webdav_name, :string
    remove_column :teams, :webdav_password, :string
    remove_column :teams, :preview_url, :string
  end
end
