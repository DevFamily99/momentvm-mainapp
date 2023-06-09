# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publishing::FindImageMatches, type: :actor do
  let(:page_module) { create(:page_module) }

  context 'when finding images succedes' do
    it 'returns array of image matches' do
      stub_find_images_success(page_modules: [page_module])
      result = described_class.call(modules: [page_module])
      expect(result.images.count).to be_positive
    end
  end

  context 'when finding images fails' do
    it 'raises error' do
      stub_find_images_failure(page_modules: [page_module])
      expect do
        described_class.call(modules: [page_module])
      end.to raise_error(ServiceActor::Failure)
    end
  end
end
