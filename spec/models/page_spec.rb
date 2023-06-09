# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Page, type: :model do
  let(:page) { create(:page) }

  describe 'validations' do
    it { should have_and_belong_to_many(:page_modules) }
    it { should have_many(:page_activities).dependent(:destroy) }
    it { should have_many(:publishing_locales).dependent(:destroy) }
    it { should have_many(:page_views).dependent(:destroy) }
    it { should have_many(:schedules) }
    it { should have_many(:page_comments).dependent(:destroy) }
    it { should have_many(:publishing_manifests).dependent(:destroy) }
    it { should have_and_belong_to_many(:country_groups) }
    it { should belong_to(:page_folder).optional }
    it { should belong_to(:team) }
    it { should define_enum_for(:translation_status) }
  end

  describe 'Last updated by helper function' do
    it 'returns None if there are no page activities' do
      expect(page.last_updated_by).to eq('None')
    end
  end
end
