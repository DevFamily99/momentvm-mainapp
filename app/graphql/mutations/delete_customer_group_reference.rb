# To remove the join table object which links a schedule
# and a CountryGroup
module Mutations
  class DeleteCustomerGroupReference < GraphQL::Schema::RelayClassicMutation
    argument :schedule_id, ID, required: true
    argument :customer_group_id, ID, required: true
    
    field :schedule, Types::ScheduleType, null: false
    field :customer_group, Types::CustomerGroupType, null: false
    
    def resolve(schedule_id:, customer_group_id:)
      schedule = Schedule.find(schedule_id)
      customer_group = CustomerGroup.find(customer_group_id)
      join_table_instance = schedule.customer_groups.find(customer_group_id)
      schedule.customer_groups.delete(join_table_instance)
      {
        schedule: schedule,
        customer_group: customer_group
      }
     end

  end
end
