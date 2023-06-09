require 'rails_helper'

RSpec.describe PageComment, type: :model do
 
  it { should belong_to(:user) }
  it { should belong_to(:page) }
  it { should validate_presence_of(:body) }

end