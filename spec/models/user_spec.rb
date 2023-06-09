# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  include ActiveJob::TestHelper
  let(:user) { create(:user, :admin) }

  describe 'validations' do
    subject { build(:user) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_length_of(:password).is_at_least(3) }
    it { should validate_presence_of(:password_confirmation) }
    it { should have_many(:page_activities) }
    it { should have_and_belong_to_many(:roles) }
    it { should have_many(:page_views) }
    it { should belong_to(:team).optional }
  end

  it 'Allowed countries helper function' do
    expect(user.allowed_countries_include?('de')).to equal(true)
  end

  it 'Send password create helper function' do
    expect { user.send_password_create }.to change { enqueued_jobs.size }.by(1)
  end

  it 'Send password reset helper function' do
    expect { user.send_password_reset }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'Has skill? helper function' do
    expect(user.has_skill?('can_create_pages')).to equal(true)
  end

  it 'By team helper function' do
    users_by_team = described_class.by_team(user)
    expect(users_by_team.any?).to be true
  end

  describe 'admin helper method' do
    it 'returns true if user admin' do
      expect(user.is_admin?).to equal(true)
    end
    it 'returns false if user not admin' do
      user.roles.destroy_all
      user.roles << create(:role, name: 'notAdmin')
      expect(user.is_admin?).to equal(false || nil)
    end
  end
end
