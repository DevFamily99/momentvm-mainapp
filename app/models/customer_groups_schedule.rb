class CustomerGroupsSchedule < ApplicationRecord
  belongs_to :customer_group
  belongs_to :schedule
end
