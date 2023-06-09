class AddPageFolderToPage < ActiveRecord::Migration[5.1]
  def change
  	add_reference :pages, :page_folder, foreign_key: true
  end
end
