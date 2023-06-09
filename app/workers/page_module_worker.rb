# Async worker to upload page modules
class PageModuleWorker
  include Sidekiq::Worker
  include PublishHelper

  sidekiq_options retry: false

  # Note:
  # Its only possible to carry over strings and ints as args.

  # Upload assets
  def perform(manifest_id, user_id)
    publish_modules(manifest_id, user_id)
  end
end
