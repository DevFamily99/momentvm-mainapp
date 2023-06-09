# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teams::GenerateCountryGroups, type: :actor do
  let!(:team) { create(:team) }

  it 'generates a demo country group' do
    described_class.call(team: team)
    expect(team.country_groups.count).to eq(1)
  end
end
