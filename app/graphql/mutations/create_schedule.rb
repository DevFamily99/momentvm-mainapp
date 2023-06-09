module Mutations
  class CreateSchedule < GraphQL::Schema::RelayClassicMutation
    field :schedule, Types::ScheduleType, null:false
    argument :page_id, ID, required: true
    argument :start_at, String, required: false
    argument :end_at, String, required: false
    argument :country_group_ids, [ID], required: false
    argument :page_module_ids, [ID], required: false

    def resolve(page_id: nil, start_at: nil, end_at: nil, country_group_ids: [], page_module_ids: [])
      schedule = Schedule.new(start_at: start_at, end_at: end_at, page_id: page_id)
      schedule.save!
      country_group_ids.each do |cg|
        CountryGroupsSchedule.create(schedule_id: schedule.id, country_group_id: cg)
      end
      page_module_ids.each do |pm|
        PageModulesSchedules.create(schedule_id: schedule.id, page_module_id: pm)
      end
      { schedule: schedule }
     end
  end
end
