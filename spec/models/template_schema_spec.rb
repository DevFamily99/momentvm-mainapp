require 'rails_helper'

RSpec.describe TemplateSchema, type: :model do
  let(:user) { create(:user) }
  let!(:template) { create(:template, :with_schema, team: user.team) }

  it { should belong_to(:template).dependent(:destroy) }
  it { should belong_to(:team).dependent(:destroy) }

  it 'By team helper function' do
    template_schema_by_team = described_class.by_team(user)
    expect(template_schema_by_team.any?).to be true
  end
end
