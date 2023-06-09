class AddPublishImagesToPublishingManifest < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    add_column :publishing_manifests, :publish_images, :boolean
  end
end
