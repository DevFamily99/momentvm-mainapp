# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teams::SetTeamAsApproved, type: :actor do
  let!(:team) { create(:team) }

  it 'generates root folders' do
    described_class.call(team: team)
    expect(team.approved).to eq(true)
  end
end
