# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teams::SetupFolders, type: :actor do
  let!(:team) { create(:team) }

  it 'generates root folders' do
    described_class.call(team: team)
    expect(team.page_folders.where(page_folder_id: nil).count).to eq(1)
    expect(team.asset_folders.where(asset_folder_id: nil).count).to eq(1)
  end
end
