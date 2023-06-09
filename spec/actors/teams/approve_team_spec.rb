# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teams::ApproveTeam, type: :actor do
  let!(:team) { create(:team) }

  it 'approves the team' do
    stub_request(:post,
                 'http://localhost:6789/api/create_team')
    .to_return(status: 200)
    stub_request(:post, "http://localhost:6789/api/team/#{team.id}/translation/new")
    .to_return(status: 200, body: '{"translation":{"id":1}}', headers: {})
    described_class.call(team: team)
    expect(team.approved).to eq(true)
  end
end
