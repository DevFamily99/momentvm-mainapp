class AddCatalogToPublishingTarget < ActiveRecord::Migration[5.2]
  def change
    add_column :publishing_targets, :catalog, :string
  end
end
