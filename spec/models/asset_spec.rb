require 'rails_helper'

RSpec.describe Asset, type: :model do
  it { should belong_to(:asset_folder).optional }
  it { should belong_to(:team) }
  it { should validate_uniqueness_of(:name).scoped_to(:team_id) }
  it { should have_one(:image_attachment) }
end
