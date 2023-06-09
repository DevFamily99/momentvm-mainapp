module Publishing
  # Broadcasts the current manifest state via the graphql subscription
  class BroadcastPublishingStatus < Actor
    input :manifest, allow_nil: false

    def call
      if manifest.schedule?
        ContentManagementSchema.subscriptions.trigger(:schedule_publishing_status, { schedule_id: manifest.schedule.id }, manifest)
      else
        ContentManagementSchema.subscriptions.trigger(:page_publishing_status, { page_id: manifest.page.id }, manifest)
      end
    end
  end
end
