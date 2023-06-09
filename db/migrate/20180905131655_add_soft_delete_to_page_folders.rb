class AddSoftDeleteToPageFolders < ActiveRecord::Migration[5.2]
  def change
    add_column :page_folders, :is_deleted, :boolean
  end
end
