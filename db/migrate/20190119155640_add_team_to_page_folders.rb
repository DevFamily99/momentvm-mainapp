class AddTeamToPageFolders < ActiveRecord::Migration[5.2]
  def change
    add_reference :page_folders, :team, foreign_key: true
  end
end
