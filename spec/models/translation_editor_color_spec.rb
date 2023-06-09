# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranslationEditorColor, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:hex) }
  # bug in  shoulda-matchers
  # https://github.com/thoughtbot/shoulda-matchers/issues/814
  # it { should validate_uniqueness_of(:name).scoped_to(:team) }
end
