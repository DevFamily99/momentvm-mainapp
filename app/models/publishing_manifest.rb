# Contains all the information around a publishing event
# The record to be created which records all parts of a publishing flow
# Like if a manifest published, was a category updated and so on
class PublishingManifest < ApplicationRecord
  # name: Used for creating the content asset manifest
  belongs_to :page
  belongs_to :publishing_target
  belongs_to :user
  belongs_to :page_context, optional: true
  belongs_to :schedule, optional: true
  has_many :publishing_events, dependent: :destroy
  # This is important only for content slot publishing since we need the sites here
  # For slot publishing we will also take the locales to render from the sites
  has_many :publishing_manifests_sites, dependent: :destroy
  has_many :sites, through: :publishing_manifests_sites
  serialize :message, Hash
  serialize :locale_codes

  def page_modules
    return schedule.valid_modules if schedule?

    page.page_modules
  end

  def finished_parts
    module_statuses = module_publishing&.message&.values&.map { |pm| pm['status'] } || []
    content_slots_statuses = content_slots_publishing&.message&.values&.map { |site| site['status'] } || []
    count = (module_statuses + content_slots_statuses).tally['success']
    count += 1 if asset_upload&.status == 'completed'
    count += 1 if manifest_publishing&.status == 'completed'
    count
  end

  def progress
    finished_parts.to_f / progress_parts
  rescue StandardError => e
    # In case of broken publishing events
    1
  end

  def schedule?
    !schedule_id.nil?
  end

  def progress_percent
    "#{progress * 100} %"
  end

  def module_publishing
    publishing_events.find_by(category: 'publish_modules')
  end

  def asset_upload
    publishing_events.find_by(category: 'upload_assets')
  end

  def content_slots_publishing
    publishing_events.find_by(category: 'publish_content_slots')
  end

  def manifest_publishing
    publishing_events.find_by(category: 'publish_manifest')
  end

  def status
    statuses = publishing_events.pluck(:status)
    return 'failed' if statuses.include?('failed')
    return 'pending' if statuses.include?('pending')

    'completed'
  end
end
