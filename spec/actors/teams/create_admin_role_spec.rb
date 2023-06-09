# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teams::CreateAdminRole, type: :actor do
  let!(:team) { create(:team) }
  let!(:user) { create(:user, team: team) }

  it 'creates the admin role for a team' do
    described_class.call(team: team)
    expect(user.roles.count).to eq(1)
  end
end
