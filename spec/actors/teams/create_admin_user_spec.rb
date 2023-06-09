# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teams::CreateAdminUser, type: :actor do
  let!(:team) { create(:team) }

  it 'creates a new admin user' do
    described_class.call(team: team)
    expect(team.users.count).to eq(1)
  end

  context 'when admin user already exists' do
    before do
      create(:user, team: team, email: team.owner_email)
    end
    it 'throws error' do
      expect do
        described_class.call(team: team)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
