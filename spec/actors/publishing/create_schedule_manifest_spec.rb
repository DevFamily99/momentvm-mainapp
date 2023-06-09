# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publishing::CreateScheduleManifest, type: :actor do
  let(:page) { create(:page) }
  let(:user) { create(:user) }
  let(:publishing_target) { create(:publishing_target, team: user.team) }
  let(:schedule) { create(:schedule, page: page) }

  context 'when schedule configuration is valid' do
    before do
      page.page_context = create(:page_context, team: page.team)
      schedule.country_groups << create(:country_group, team: page.team)
      schedule.page_modules << create(:page_module, team: page.team)
    end

    it 'creates a new publishing manifest' do
      manifest = described_class.call(user: user, publishing_target: publishing_target, schedule: schedule).manifest
      expect(manifest).to be_instance_of(PublishingManifest)
    end
  end

  context 'when page_context is not set' do
    it 'raises error' do
      expect do
        described_class.call(user: user, publishing_target: publishing_target, schedule: schedule)
      end.to raise_error(ServiceActor::Failure)
    end
  end

  context 'when country groups are not set' do
    before do
      page.page_context = create(:page_context, team: page.team)
    end

    it 'raises error' do
      expect do
        described_class.call(user: user, publishing_target: publishing_target, schedule: schedule)
      end.to raise_error(ServiceActor::Failure)
    end
  end

  context 'when schedule has no valid modules' do
    before do
      page.page_context = create(:page_context, team: page.team)
      schedule.country_groups << create(:country_group, team: page.team)
    end

    it 'raises error' do
      expect do
        described_class.call(user: user, publishing_target: publishing_target, schedule: schedule)
      end.to raise_error(ServiceActor::Failure)
    end
  end
end
