# To remove the join table object which links a schedule
# and a CountryGroup
module Mutations
  class DeleteCountryGroupReference < GraphQL::Schema::RelayClassicMutation
    #field :schedule_country_group, Types::ScheduleCountryGroupType, null:false
    argument :schedule_id, ID, required: true
    argument :country_group_id, ID, required: true
    
    field :schedule, Types::ScheduleType, null: false
    field :country_group, Types::CountryGroupType, null: false
    
    def resolve(schedule_id:, country_group_id:)
      schedule = Schedule.find(schedule_id)
      country_group = CountryGroup.find(country_group_id)
      join_table_instance = schedule.country_groups.find(country_group_id)
      schedule.country_groups.delete(join_table_instance)
      {
        schedule: schedule,
        country_group: country_group
      }
     end

  end
end
