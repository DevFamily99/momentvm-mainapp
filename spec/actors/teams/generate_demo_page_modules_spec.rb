# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teams::GenerateDemoPageModules, type: :actor do
  let!(:team) { create(:team) }
  let!(:user) { create(:user, team: team) }
  let!(:page) { create(:page, team: team) }

  it 'generates demo modules' do
    Teams::SetupFolders.call(team: team)
    Teams::GenerateTemplates.call(team: team)
    stub_request(:post, "http://localhost:6789/api/team/#{team.id}/translation/new")
      .to_return(status: 200, body: '{"translation":{"id":1}}', headers: {})
    described_class.call(team: team, page: page)
    expect(page.page_modules.count).to eq(9)
  end
end
