# frozen_string_literal: true

class CountryGroup < ApplicationRecord
  has_and_belongs_to_many :sites
  has_and_belongs_to_many :schedules
  has_and_belongs_to_many :pages
  belongs_to :team
  has_many :country_groups_locales, dependent: :destroy
  has_many :locales, through: :country_groups_locales
  validates :name, presence: true, uniqueness: { scope: :team }

  # returns an array of locale codes: [de-DE, fr-FR]
  def locale_codes
    locales.map(&:code).uniq
  end
end
