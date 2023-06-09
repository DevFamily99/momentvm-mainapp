class AddTeamToAssetFolders < ActiveRecord::Migration[5.2]
  def change
    add_reference :asset_folders, :team, foreign_key: true, on_delete: :cascade
  end
end
