class AddEncryptionIvsToPublishingTarget < ActiveRecord::Migration[5.2]
  def change
    add_column :publishing_targets, :encrypted_webdav_username_iv, :string
    add_column :publishing_targets, :encrypted_webdav_password_iv, :string
  end
end
