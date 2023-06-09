class CreateSitesPublishingManifests < ActiveRecord::Migration[5.2]
  def change
    create_table :publishing_manifests_sites do |t|
      t.references :site, foreign_key: true
      t.references :publishing_manifest, foreign_key: true
    end
  end
end