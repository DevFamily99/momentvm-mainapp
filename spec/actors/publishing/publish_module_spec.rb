# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publishing::PublishModule, type: :actor do
  let(:page) { create(:page) }
  let(:user) { create(:user) }
  let(:publishing_target) { create(:publishing_target, team: user.team) }
  let(:schedule) { create(:schedule, page: page) }

  before do
    page.page_context = create(:page_context, team: page.team)
    schedule.country_groups << create(:country_group, team: page.team)
    schedule.page_modules << create(:page_module, team: page.team)
  end

  context 'when publishing a module succedes' do
    it 'updates the publishing event with the result' do # rubocop:disable RSpec/ExampleLength
      manifest = Publishing::CreateScheduleManifest.call(user: user, publishing_target: publishing_target, schedule: schedule).manifest
      Publishing::CreatePublishingEvents.call(manifest: manifest)
      page_module = schedule.valid_modules.first
      stub_publish_module_success(manifest: manifest, page_module: page_module)
      described_class.call(manifest: manifest, page_module: page_module)
      expect(manifest.module_publishing.message[page_module.id]['status']).to eq 'success'
    end
  end

  context 'when publishing a module fails' do
    it 'updates the publishing event with the result' do # rubocop:disable RSpec/ExampleLength
      manifest = Publishing::CreateScheduleManifest.call(user: user, publishing_target: publishing_target, schedule: schedule).manifest
      Publishing::CreatePublishingEvents.call(manifest: manifest)
      page_module = schedule.valid_modules.first
      stub_publish_module_failure(manifest: manifest, page_module: page_module)
      described_class.call(manifest: manifest, page_module: page_module)
      expect(manifest.module_publishing.message[page_module.id]['status']).to eq 'failed'
    end
  end
end
