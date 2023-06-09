# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teams::GenerateTemplates, type: :actor do
  let!(:team) { create(:team) }

  it 'generates demo templates' do
    described_class.call(team: team)
    expect(team.templates.count).to eq(7)
  end
end
