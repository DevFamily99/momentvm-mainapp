require 'rails_helper'

RSpec.describe PublishingManifest, type: :model do
  it { is_expected.to belong_to(:page) }
  it { is_expected.to belong_to(:publishing_target) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:publishing_events).dependent(:destroy) }
end
