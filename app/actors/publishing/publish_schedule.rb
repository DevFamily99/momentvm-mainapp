module Publishing
  # Publishes a schedule
  class PublishSchedule < Actor
    play CreateScheduleManifest, CreatePublishingEvents, PublishModules, PublishContentSlots
    play PublishImages, if: ->(result) { result.manifest.publish_images }
  end
end
