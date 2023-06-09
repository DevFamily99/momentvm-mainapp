# Represents a single publishing event
class PublishingEvent < ApplicationRecord
  belongs_to :publishing_manifest
  STATUTES = %w[pending completed failed].freeze
  CATEGORIES = %w[publish_modules upload_assets publish_content_slots publish_manifest].freeze

  validates :status, presence: true, inclusion: { in: PublishingEvent::STATUTES }
  validates :category, presence: true, inclusion: { in: PublishingEvent::CATEGORIES }

  # serialize :message, YAML

  store :message, coder: YAML

  def display_name
    case category
    when 'publish_modules'
      'Content Assets'
    when 'upload_assets'
      'Images'
    when 'publish_content_slots'
      'Content Slots'
    when 'publish_manifest'
      'Manifest'
    else
      category
    end
  end
end
