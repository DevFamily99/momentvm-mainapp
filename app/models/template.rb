# frozen_string_literal: true

class Template < ApplicationRecord
  include PgSearch::Model

  scope :archived, -> { where(archived: true) }
  scope :unarchived, -> { where(archived: false) }

  multisearchable(against: [:id, :name], additional_attributes: ->(template) { { team_id: template.team_id } })
  pg_search_scope :search,
                  against: %i[id name],
                  associated_against: {
                    tags: %i[id name]
                  }

  has_one :template_schema, dependent: :destroy
  has_many :template_tags, dependent: :destroy
  has_many :tags, through: :template_tags
  has_many :page_modules, dependent: :destroy
  has_one_attached :image
  belongs_to :team
  has_paper_trail only: [:body]

  validate :name_cannot_contain_slashes
  validates :name, uniqueness: { scope: :team_id }

  def self.by_team(current_user)
    Template.where(team_id: current_user.team_id)
  end

  def name_cannot_contain_slashes
    errors.add(:name, 'cannot contain slashes') if name.include?('/') || name.include?('\\')
  end
end
