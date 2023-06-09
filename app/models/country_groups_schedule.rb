class CountryGroupsSchedule < ApplicationRecord
  belongs_to :country_group
  belongs_to :schedule
end
