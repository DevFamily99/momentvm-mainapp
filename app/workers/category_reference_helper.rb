# Async worker to update the reference from a content asset manifest
# and a category
class CategoryReferenceHelper
  include Sidekiq::Worker
  include PublishHelper

  sidekiq_options retry: false

  # Category reference update
  def perform(manifest_id, context, user_id)
    update_category(manifest_id, context, user_id)
  end
end
