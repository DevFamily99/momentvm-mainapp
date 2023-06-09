# Used to keep track of translation projects on third party apis
class TranslationProject < ApplicationRecord
  #   validates :submission_id, presence: true, uniqueness: { scope: :team }
  validates :provider, presence: true
  belongs_to :team
  enum provider: { lw: 'LW', globallink: 'GLOBALLINK' }
end
