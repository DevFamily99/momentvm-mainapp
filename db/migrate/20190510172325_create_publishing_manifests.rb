class CreatePublishingManifests < ActiveRecord::Migration[5.2]
  def change
    create_table :publishing_manifests do |t|
      t.references :page, foreign_key: true
      t.references :publishing_target, foreign_key: true
      t.integer :progress_parts
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
