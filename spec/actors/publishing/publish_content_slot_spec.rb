# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publishing::PublishContentSlot, type: :actor do
  let(:page) { create(:page) }
  let(:user) { create(:user) }
  let(:publishing_target) { create(:publishing_target, team: user.team) }
  let(:schedule) { create(:schedule, page: page) }

  before do
    page.page_context = create(:page_context, team: page.team)
    schedule.country_groups << create(:country_group, team: page.team)
    schedule.page_modules << create(:page_module, team: page.team)
  end

  context 'when publishing a content slot succedes' do
    it 'updates the publishing event with the result' do
      manifest = Publishing::CreateScheduleManifest.call(user: user, publishing_target: publishing_target, schedule: schedule).manifest
      Publishing::CreatePublishingEvents.call(manifest: manifest)
      stub_publish_content_slot_success(manifest: manifest, site: manifest.sites.first)
      described_class.call(manifest: manifest, site: manifest.sites.first)
      expect(manifest.content_slots_publishing.message[manifest.sites.first.salesforce_id]['status']).to eq 'success'
    end
  end

  context 'when publishing a content slot' do
    it 'updates the publishing event with the result' do
      manifest = Publishing::CreateScheduleManifest.call(user: user, publishing_target: publishing_target, schedule: schedule).manifest
      Publishing::CreatePublishingEvents.call(manifest: manifest)
      stub_publish_content_slot_failure(manifest: manifest, site: manifest.sites.first)
      described_class.call(manifest: manifest, site: manifest.sites.first)
      expect(manifest.content_slots_publishing.message[manifest.sites.first.salesforce_id]['status']).to eq 'failed'
    end
  end
end
