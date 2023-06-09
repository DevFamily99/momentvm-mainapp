# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, type: :model do
  it { should have_many(:publishing_targets) }
  it { should have_many(:settings) }
  it { should have_many(:users) }
  it { should have_many(:page_folders) }
  it { should have_many(:pages) }
  it { should have_many(:assets) }
  it { should have_many(:asset_folders) }
  it { should have_many(:templates) }
  it { should have_many(:template_schemas) }
  it { should have_many(:country_groups) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_uniqueness_of(:owner_email) }
  it { should validate_presence_of(:owner_firstname) }
  it { should validate_presence_of(:owner_firstname) }
  it { should have_many(:pages).dependent(:destroy) }
  it { should have_many(:page_folders).dependent(:destroy) }
  it { should have_many(:asset_folders).dependent(:destroy) }
end
