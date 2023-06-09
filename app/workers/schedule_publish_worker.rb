# Publishes a Content Slot
class SchedulePublishWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  # Note:
  # Its only possible to carry over strings and ints as args.

  # Publish a schedule
  def perform(user_id, publishing_target_id, schedule_id)
    user = User.find(user_id)
    schedule = Schedule.find(schedule_id)
    publishing_target = PublishingTarget.find(publishing_target_id)
    begin
      Publishing::PublishSchedule.call(user: user, publishing_target: publishing_target, schedule: schedule)
    rescue StandardError => e
      # Fail all pending publishing events
      manifest = schedule.publishing_manifests.last
      pending_events = manifest.publishing_events.where(status: 'pending')
      Publishing::BroadcastPublishingStatus.call(manifest: manifest) if pending_events.update(status: 'failed', message: { MOMENTVM: { status: 'failed', error: e.message } })
    end
  end
end
