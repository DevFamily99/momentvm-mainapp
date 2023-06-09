class Tag < ApplicationRecord
  belongs_to :team

  has_many :template_tags, dependent: :destroy
  has_many :templates, through: :template_tags

  validates :name, uniqueness: { scope: :team_id }
end
