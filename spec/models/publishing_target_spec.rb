require 'rails_helper'

RSpec.describe PublishingTarget, type: :model do

  it { should belong_to(:team) }
  it { should have_many(:publishing_manifests).dependent(:destroy) }

end