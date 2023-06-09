# frozen_string_literal: true

module Mutations
  # Publishes a schedules content to salesforce
  class PublishSchedule < GraphQL::Schema::RelayClassicMutation
    field :schedule, Types::ScheduleType, null: false
    argument :id, ID, required: true
    argument :publishing_target_id, ID, required: true

    def resolve(id:, publishing_target_id:)
      current_user = context[:current_user]
      schedule = Schedule.find(id)

      raise 'Page context is not set' if schedule.page.page_context.nil?
      raise 'Selected schedule does not have valid country groups' if schedule.country_groups.empty?
      raise GraphQL::ExecutionError.new('Selected schedule does not have any modules assigned to it') if schedule.valid_modules.empty?

      publishing_target = PublishingTarget.find(publishing_target_id)
      SchedulePublishWorker.perform_async(current_user.id, publishing_target.id, schedule.id)
      { schedule: schedule }
    end
  end
end
