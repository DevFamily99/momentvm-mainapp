require 'rails_helper'

RSpec.describe PageModule, type: :model do
  it { is_expected.to belong_to(:template) }
  it { is_expected.to serialize(:body) }
end
