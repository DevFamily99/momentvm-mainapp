module Types
  class ScheduleCountryGroupType < BaseObject
    field :schedule_id, ID, null: false
    field :country_group_id, ID, null: false
  end
end
