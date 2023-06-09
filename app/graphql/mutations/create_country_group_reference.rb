# This mutation creates an entry in the join table between CountryGroup and Schedule
module Mutations
  class CreateCountryGroupReference < GraphQL::Schema::RelayClassicMutation
    #field :schedule_country_group, Types::ScheduleCountryGroupType, null: true

    argument :schedule_id, ID, required: true
    argument :country_group_id, ID, required: false
  
    field :schedule, Types::ScheduleType, null: false
    field :country_group, Types::CountryGroupType, null: false
    

    def resolve(schedule_id:, country_group_id:)
      schedule = Schedule.find(schedule_id)
      country_group = CountryGroup.find(country_group_id)
      unless schedule.country_groups.include? country_group
        schedule.country_groups << country_group
        schedule.save!
      end
      {
        schedule: schedule,
        country_group: country_group
      }
     end
  end
end
