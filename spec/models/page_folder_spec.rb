require 'rails_helper'

RSpec.describe PageFolder, type: :model do

  it { should belong_to(:page_folder).optional() }
  it { should have_many(:pages) }
  it { should have_many(:page_folders) }
  it { should validate_presence_of(:name) }
  it { should belong_to(:team) }
  
end