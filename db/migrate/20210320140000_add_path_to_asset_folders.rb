class AddPathToAssetFolders < ActiveRecord::Migration[6.0] #:nodoc:
  def change
    add_column :asset_folders, :path, :string
    add_index :asset_folders, :path, unique: true
  end
end
