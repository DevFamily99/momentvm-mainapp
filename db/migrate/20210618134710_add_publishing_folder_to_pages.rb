class AddPublishingFolderToPages < ActiveRecord::Migration[6.0] #:nodoc:
  def change
    add_column :pages, :publishing_folder, :string
  end
end
