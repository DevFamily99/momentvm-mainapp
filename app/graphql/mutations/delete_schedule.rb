module Mutations
  class DeleteSchedule < GraphQL::Schema::RelayClassicMutation
    field :schedule, Types::ScheduleType, null:false
    argument :id, ID, required: true
  
    def resolve(id:)
      schedule = Schedule.find(id)
      schedule.destroy!
      
      { schedule: schedule }
     end

  end
end
