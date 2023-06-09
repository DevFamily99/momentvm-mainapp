class CreatePublishingEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :publishing_events do |t|
      t.references :publishing_manifest, foreign_key: true
      t.string :category
      t.text :message

      t.timestamps
    end
  end
end
