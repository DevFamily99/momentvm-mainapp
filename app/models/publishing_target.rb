class PublishingTarget < ApplicationRecord
  belongs_to :team
  has_many :publishing_manifests, dependent: :destroy
  attr_encrypted :webdav_username, key: Rails.application.credentials.key
  attr_encrypted :webdav_password, key: Rails.application.credentials.key

  validates :publishing_url, format: { with: /(net|com|de)\Z/i, message: 'Cannot end with a slash!' }
end
