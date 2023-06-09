class AddFolderAssignmentsToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :folder_assignments, :text
  end
end
