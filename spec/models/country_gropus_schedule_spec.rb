require 'rails_helper'

RSpec.describe CountryGroupsSchedule, type: :model do
 
  it { should belong_to(:country_group) }  
  it { should belong_to(:schedule) }
  
end