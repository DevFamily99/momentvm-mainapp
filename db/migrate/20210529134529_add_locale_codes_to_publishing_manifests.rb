class AddLocaleCodesToPublishingManifests < ActiveRecord::Migration[6.0] #:nodoc:
  def change
    add_column :publishing_manifests, :locale_codes, :string
  end
end
