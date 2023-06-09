# Async worker to upload page manifest
class PageManifestWorker
  include Sidekiq::Worker
  include PublishHelper
  sidekiq_options retry: false

  # Note:
  # Its only possible to carry over strings and ints as args.

  # Upload assets
  def perform(manifest_id, user_id)
    publish_modules(manifest_id, user_id)
    publish_manifest_new_page(manifest_id, user_id)
  end
end
