class CreateAssetFolders < ActiveRecord::Migration[5.1]
  def change
    create_table :asset_folders do |t|
      t.string :name
      t.references :asset_folder, foreign_key: true

      t.timestamps
    end
  end
end
