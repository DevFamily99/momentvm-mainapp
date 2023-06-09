# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teams::SendApprovedMail, type: :actor do
  include ActiveJob::TestHelper

  let!(:team) { create(:team) }
  let!(:user) { create(:user, team: team) }

  it 'generates demo page' do
    described_class.call(team: team)
    expect(enqueued_jobs.size).to eq(1)
  end
end
