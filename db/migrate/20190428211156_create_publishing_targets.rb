class CreatePublishingTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :publishing_targets do |t|
      t.string :name
      t.string :publishing_url
      t.string :encrypted_webdav_username
      t.string :encrypted_webdav_password
      t.string :webdav_path
      t.string :preview_url
      t.references :team, foreign_key: true

      t.timestamps
    end
  end
end
