require 'rails_helper'

RSpec.describe PageActivity, type: :model do
 
  it { should belong_to(:user).optional() }
  it { should belong_to(:page) }

end