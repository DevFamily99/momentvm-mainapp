# frozen_string_literal: true

module Mutations
  class UpdateSchedule < GraphQL::Schema::RelayClassicMutation
    field :schedule, Types::ScheduleType, null: false

    argument :id, ID, required: true
    argument :start_at, String, required: false
    argument :end_at, String, required: false
    argument :campaign_id, String, required: false
    argument :country_groups, [String], required: false
    argument :customer_groups, [String], required: false
    argument :page_module_ids, [String], required: false
    #    def resolve(id:, start_at: nil, end_at: nil, country_group_ids: nil, page_module_ids: nil)

    def resolve(input)
      schedule = Schedule.find(input[:id])
      schedule.start_at = input[:start_at] if input.key?(:start_at)
      schedule.end_at = input[:end_at] if input.key?(:end_at)
      schedule.campaign_id = input[:campaign_id] if input.key?(:campaign_id)
      unless schedule.country_groups.ids == input[:country_groups]

        if input[:country_groups]
          if input[:country_groups].include?('none')
            schedule.country_groups = []
          else
            CountryGroupsSchedule.where(schedule_id: schedule.id).where.not(country_group_id: input[:country_groups]).destroy_all
            newCountryGroups = CountryGroup.find(input[:country_groups])
            newCountryGroups.each { |cg| schedule.country_groups << cg unless schedule.country_groups.ids.include?(cg.id) }
          end
        end
      end
      unless schedule.customer_groups.ids == input[:customer_groups]
        if input[:customer_groups]
          if input[:customer_groups].include?('none')
            schedule.customer_groups = []
          else
            CustomerGroupsSchedule.where(schedule_id: schedule.id).where.not(customer_group_id: input[:customer_groups]).destroy_all
            newCustomerGroups = CustomerGroup.find(input[:customer_groups])
            newCustomerGroups.each { |cg| schedule.customer_groups << cg unless schedule.customer_groups.ids.include?(cg.id) }
          end
        end
      end
      schedule.save
      if input[:page_module_ids]
        PageModulesSchedules.where(schedule_id: schedule.id).delete_all
        input[:page_module_ids].each do |pmi|
          PageModulesSchedules.create(schedule_id: schedule.id, page_module_id: pmi)
        end
      end

      { schedule: schedule }
    end
  end
end
