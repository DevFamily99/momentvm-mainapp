class AddSlugToAssetFolders < ActiveRecord::Migration[6.0]
  def change
    add_column :asset_folders, :slug, :string
    add_index :asset_folders, :slug, unique: true
  end
end
