# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schedule, type: :model do
  it { should belong_to(:page) }
  it { should have_and_belong_to_many(:country_groups) }
  it { should have_and_belong_to_many(:page_modules) }
end
