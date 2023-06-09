# frozen_string_literal: true

# A Page schedule
# Has a start and end date, CountryGroups
# The screenshot status field has 3 states
# 0 - no screenshot uploaded
# 1 - screenshot exists but dosen't show latest changes
# 2 - screenshot shows latest changes
class Schedule < ApplicationRecord
  enum screenshot_status: { waiting: 0, outdated: 1, up_to_date: 2 }
  belongs_to :page
  has_one_attached :thumbnail
  has_many :publishing_manifests, dependent: :destroy
  has_and_belongs_to_many :country_groups
  has_and_belongs_to_many :customer_groups
  has_and_belongs_to_many :page_modules

  # returns an array of locale codes: [de-DE, fr-FR]
  def locale_codes
    country_groups.map(&:locale_codes).flatten.uniq
  end

  def valid_modules
    own_modules = page_modules
    unassigned = page.page_modules.unscheduled
    (own_modules + unassigned).uniq.sort_by(&:rank)
  end
end
