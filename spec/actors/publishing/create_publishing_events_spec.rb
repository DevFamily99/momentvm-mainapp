# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publishing::CreatePublishingEvents, type: :actor do
  context 'when publishing a schedule' do
    context 'when image upload is enabled' do
      let(:manifest) { create(:publishing_manifest, schedule: create(:schedule), publish_images: true) }

      it 'creates 3 publishing events for the publishing manifest' do
        described_class.call(manifest: manifest)
        expect(manifest.publishing_events.count).to eq(3)
      end
    end

    context 'when image upload is disabled' do
      let(:manifest) { create(:publishing_manifest, schedule: create(:schedule)) }

      it 'creates 2 publishing events for the publishing manifest' do
        described_class.call(manifest: manifest)
        expect(manifest.publishing_events.count).to eq(2)
      end
    end
  end

  context 'when publishing a content asset' do
    context 'when image upload is enabled' do
      let(:manifest) { create(:publishing_manifest, publish_images: true) }

      it 'creates 3 publishing events for the publishing manifest' do
        described_class.call(manifest: manifest)
        expect(manifest.publishing_events.count).to eq(3)
      end
    end

    context 'when image upload is disabled' do
      let(:manifest) { create(:publishing_manifest) }

      it 'creates 2 publishing events for the publishing manifest' do
        described_class.call(manifest: manifest)
        expect(manifest.publishing_events.count).to eq(2)
      end
    end
  end
end
