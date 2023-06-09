# Async worker to upload images
class FileUploadWorker
  include Sidekiq::Worker
  include PublishHelper

  sidekiq_options retry: false

  # Upload assets
  def perform(manifest_id, page_id, publishing_target_id, team_id)
    upload_assets(manifest_id, page_id, publishing_target_id, team_id)
  end
end
