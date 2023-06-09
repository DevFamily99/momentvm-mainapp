module Publishing
  # Create the publishing events for publishing a content asset or a schedule
  class CreatePublishingEvents < Actor
    input :manifest, allow_nil: false

    def call
      PublishingEvent.create!(publishing_manifest: manifest, message: manifest.page_modules.map { |m| [m.id, { status: 'pending' }] }.to_h, category: 'publish_modules', status: 'pending')
      PublishingEvent.create!(publishing_manifest: manifest, category: 'upload_assets', status: 'pending') if manifest.publish_images?
      PublishingEvent.create!(publishing_manifest: manifest, message: manifest.sites.map { |m| [m.salesforce_id, { status: 'pending' }] }.to_h, category: 'publish_content_slots', status: 'pending') if manifest.schedule?
      PublishingEvent.create!(publishing_manifest: manifest, category: 'publish_manifest', status: 'pending') unless manifest.schedule?
    end
  end
end
