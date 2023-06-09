require 'rails_helper'

RSpec.describe CountryGroupsPage, type: :model do
 
  it { should belong_to(:page) }  
  it { should belong_to(:page) }
  
end