# Publishes a Content Slot
class PagePublishWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  # Note:
  # Its only possible to carry over strings and ints as args.

  # Publish a page
  def perform(user_id, publishing_target_id, page_id)
    user = User.find(user_id)
    page = Page.find(page_id)
    publishing_target = PublishingTarget.find(publishing_target_id)
    begin
      Publishing::PublishContentAsset.call(user: user, publishing_target: publishing_target, page: page)
    rescue StandardError => e
      p e
      # Fail all pending publishing events
      manifest = page.publishing_manifests.last
      pending_events = manifest.publishing_events.where(status: 'pending')
      pending_events.each do |event|
        event.update!(status: 'failed', message: { MOMENTVM: { status: 'failed', error: e.message } })
      end
      Publishing::BroadcastPublishingStatus.call(manifest: manifest)
    end
  end
end
