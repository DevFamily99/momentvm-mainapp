module Types
  # A publishing manifest created when publishing a page
  class PublishingManifestType < BaseObject
    field :id, ID, null: false
    field :publishing_events, [PublishingEventType], null: true
    field :publishing_target, PublishingTargetType, null: false
    field :schedule, ScheduleType, null: true
    field :user, UserType, null: false
    field :status, String, null: false
    field :updated_at, String, null: false
    field :created_at, String, null: false
    field :module_publishing, PublishingEventType, null: true
    field :manifest_publishing, PublishingEventType, null: true
    field :content_slots_publishing, PublishingEventType, null: true
    field :asset_upload, PublishingEventType, null: true
    field :locale_codes, [String], null: true
    field :parts, Integer, null: false
    field :finished_parts, Integer, null: true
    field :progress, Float, null: false

    def parts
      object.progress_parts
    end

    def locale_codes
      object.locale_codes || []
    end

    def created_at
      object.created_at.to_s(:rfc822)
    end
  end
end
