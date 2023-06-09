class AddAssetFolderToAsset < ActiveRecord::Migration[5.1]
  def change
    add_reference :assets, :asset_folder, foreign_key: true
  end
end
