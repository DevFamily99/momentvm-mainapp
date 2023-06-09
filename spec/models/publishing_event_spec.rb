require 'rails_helper'

RSpec.describe PublishingEvent, type: :model do

  it { should belong_to(:publishing_manifest) }

end