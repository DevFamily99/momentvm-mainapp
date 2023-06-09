require 'rails_helper'

RSpec.describe Template, type: :model do
  let(:user) { create(:user) }
  let(:subject) { create(:template, team: user.team) }

  before do
    create(:template, name: 'test', team: user.team)
  end

  describe 'validations' do
    it { is_expected.to have_one(:template_schema).dependent(:destroy) }
    it { is_expected.to have_many(:page_modules).dependent(:destroy) }
    it { is_expected.to belong_to(:team) }
  end

  it 'By team helper function' do
    templates_by_team = described_class.by_team(user)
    expect(templates_by_team.any?).to be true
  end
end
