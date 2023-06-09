# frozen_string_literal: true

class TranslationEditorColor < ApplicationRecord
  validates :name, :hex, presence: true, uniqueness: { scope: :team }
  belongs_to :team
end
