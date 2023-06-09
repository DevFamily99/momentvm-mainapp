require 'rails_helper'

RSpec.describe Setting, type: :model do

	it { should belong_to(:team) }

end