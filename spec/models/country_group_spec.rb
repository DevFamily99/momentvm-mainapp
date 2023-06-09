require 'rails_helper'

RSpec.describe CountryGroup, type: :model do
  it { is_expected.to belong_to(:team) }
  it { is_expected.to have_and_belong_to_many(:schedules) }
end
