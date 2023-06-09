class AddPathToPageFolders < ActiveRecord::Migration[6.0] #:nodoc:
  def change
    add_column :page_folders, :path, :string
    add_index :page_folders, :path, unique: true
  end
end
