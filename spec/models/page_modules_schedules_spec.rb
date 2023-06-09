require 'rails_helper'

RSpec.describe PageModulesSchedules, type: :model do

  it { should belong_to(:schedule) }
  it { should belong_to(:page_module) }

end