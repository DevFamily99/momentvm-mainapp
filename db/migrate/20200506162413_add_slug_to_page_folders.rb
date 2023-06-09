class AddSlugToPageFolders < ActiveRecord::Migration[6.0]
  def change
    add_column :page_folders, :slug, :string
    add_index :page_folders, :slug, unique: true
  end
end
