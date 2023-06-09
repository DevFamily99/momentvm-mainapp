require 'rails_helper'

RSpec.describe AssetFolder, type: :model do
  it { should belong_to(:asset_folder).optional }
  it { should have_many(:assets) }
  it { should belong_to(:team) }
  it { should validate_presence_of(:name) }
end
