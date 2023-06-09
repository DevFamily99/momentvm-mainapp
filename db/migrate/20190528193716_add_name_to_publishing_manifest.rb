class AddNameToPublishingManifest < ActiveRecord::Migration[5.2]
  def change
    add_column :publishing_manifests, :name, :string
  end
end
