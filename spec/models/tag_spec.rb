require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:subject) { create(:tag) }

  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:team_id) }
end
