module Types
  # Define all subscriptions here
  class SubscriptionType < BaseObject # GraphQL::Schema::Objec

    description "Find the latest publishing manifest for a schedule"    
    # subscription SchedulePublishingStatus($scheduleId: ID!) {
    #   schedulePublishingStatus(scheduleId: $scheduleId) { <- field name
    #     parts
    #     progress
    # For this argument return a publishing manifest
    field :schedule_publishing_status, Types::PublishingManifestType, null: true do
      argument :schedule_id, ID, required: true
    end
  
    # resolver
    def schedule_publishing_status(schedule_id:)
      PublishingManifest.where(schedule_id: schedule_id).order("created_at").last
    end



    description "Find the latest publishing manifest for a page"    
    field :page_publishing_status, Types::PublishingManifestType, null: true do
      argument :page_id, ID, required: true
    end
  
    # resolver
    def page_publishing_status(page_id:)
      pm = PublishingManifest.where(page_id: page_id).order("created_at").last
      pm
    end



    description "Find page comments for a given page"    
    field :page_comments, [Types::PageCommentType], null: false do
      argument :page_id, ID, required: true
    end
  
    def page_comments(page_id:)
      PageComment.where(page_id: page_id)
    end

  end
end
