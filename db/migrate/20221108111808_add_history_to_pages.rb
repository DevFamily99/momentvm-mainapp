class AddHistoryToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :last_published, :datetime
    add_column :pages, :duplicated_from_page_link, :string
    add_column :pages, :duplicated_from_page, :datetime
    add_column :pages, :last_sent_to_translation, :datetime
    add_column :pages, :last_imported_translation, :datetime
    add_column :pages, :deleted_from_archive, :datetime
  end
end
