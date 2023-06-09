class CreatePageFolders < ActiveRecord::Migration[5.1]
  def change
    create_table :page_folders do |t|
      t.string :name
      t.references :page_folder, foreign_key: true
      t.timestamps
    end
  end
end
