# frozen_string_literal: true

class PageModule < ApplicationRecord
  after_update :set_schedule_screenshot_status
  before_destroy :delete_from_schedules
  has_and_belongs_to_many :schedules
  has_and_belongs_to_many :pages
  belongs_to :page_module, optional: true
  has_many :page_modules, dependent: :destroy
  has_many :blueprint_page_modules
  has_many :blueprints, through: :blueprint_page_modules
  scope :unscheduled, -> { left_outer_joins(:schedules).where(schedules: { page_modules: nil }) }
  include Rails.application.routes.url_helpers

  # belongs_to :page
  belongs_to :template
  belongs_to :team
  serialize :body

  has_many :page_module_role_whitelists, dependent: :destroy
  has_paper_trail # Versioning

  delegate :name, to: :template, prefix: true

  def page_ids
    pages.as_json
  end

  def self.not_blacklisted_for_country(country_id)
    where("not exists (select * from page_module_blacklists bl where bl.page_module_id = page_modules.id and bl.country_id = #{country_id})")
  end

  def self.blacklisted_for_country(country_id)
    where("exists (select * from page_module_blacklists bl where bl.page_module_id = page_modules.id and bl.country_id = #{country_id})")
  end

  # filters out blacklisted countries
  # country_array is an array of country codes
  def filter_countries(country_array)
    blacklisted = blacklist.pluck(:code)
    country_array.map do |c|
      return c unless blacklisted.include?(c)
    end
  end

  def set_schedule_screenshot_status
    # Schedules
    schedules.each do |schedule|
      schedule.screenshot_status = :outdated if schedule.screenshot_status == :up_to_date
      schedule.save
    end
    # Pages
    pages.each do |page|
      page.screenshot_status = :outdated if page.screenshot_status == :up_to_date
      page.save
    end
  end

  # depandent: :destroy wasn't woking
  def delete_from_schedules
    PageModulesSchedules.where(page_module_id: id).delete_all
  end

  # Returns a uui that can be used for Salesforce publishing
  # For a page module content asset
  def sfcc_id(manifest)
    team_initials = team.initials ? "#{team.initials}_" : ''

    # New page with schedule
    return "#{team_initials}#{manifest.schedule.id}_#{id}" if manifest.schedule?

    # No schedule
    "#{team_initials + manifest.page.context}_#{id}"
  end
end
