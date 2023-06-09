# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teams::GenerateDemoPage, type: :actor do
  let!(:team) { create(:team) }
  let!(:user) { create(:user, team: team) }

  it 'generates demo page' do
    Teams::SetupFolders.call(team: team)
    Teams::GenerateTemplates.call(team: team)
    stub_request(:post, "http://localhost:6789/api/team/#{team.id}/translation/new")
      .to_return(status: 200, body: '{"translation":{"id":1}}', headers: {})
    described_class.call(team: team)
    expect(team.pages.count).to eq(1)
  end
end
