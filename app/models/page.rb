# frozen_string_literal: true

# context: Classic page category context e.g. "root"
# context_type: Classic page type: "category" or "content asset" or "supports_schedules"
# if supports_schedules then its a next gen page
# page context: New page context object reference
class Page < ApplicationRecord
  require 'micro_service'
  require 'content_renderer'
  include PgSearch::Model
  include UsersHelper
  include Rails.application.routes.url_helpers
  multisearchable(
    against: [:id, :name],
    additional_attributes: ->(page) { { team_id: page.team_id } }
  )

  scope :articles, -> { where(context_type: 'article') }  
  has_and_belongs_to_many :page_modules, dependent: :destroy
  has_and_belongs_to_many :country_groups, dependent: :destroy
  has_many :page_activities, dependent: :destroy
  has_many :publishing_locales, dependent: :destroy
  has_many :page_views, dependent: :destroy
  has_many :page_comments, dependent: :destroy
  has_many :publishing_manifests, dependent: :destroy
  has_many :schedules, dependent: :destroy
  belongs_to :page_context, optional: true
  belongs_to :page_folder, optional: true
  belongs_to :team
  has_one_attached :thumbnail

  enum translation_status: {
    unset: 0,
    sent_for_validation: 1,
    waiting_for_translation: 2,
    translated: 3
  }

  enum screenshot_status: {
    waiting: 0, outdated: 1, up_to_date: 2
  }

  has_paper_trail only: [ :created_at, :updated_at, 
    :last_published, :last_sent_to_translation, 
    :last_imported_translation, :deleted_from_archive,
    :duplicated_from_page
  ] 
  

  def created_by
    u_id = self.versions.where("object_changes -> 'created_at' IS NOT NULL")&.first&.whodunnit
    User.find_by(id: u_id)&.name unless u_id.nil?
  end

  def updated_by
    u_id = self.versions.where("object_changes -> 'updated_at' IS NOT NULL")&.reverse&.first&.whodunnit
    User.find_by(id: u_id)&.name unless u_id.nil?
  end

  def send_to_translation_by
    u_id = self.versions.where("object_changes -> 'last_sent_to_translation' IS NOT NULL")&.reverse&.first&.whodunnit
    User.find_by(id: u_id)&.name unless u_id.nil?
  end

  def translation_imported_by
    u_id = self.versions.where("object_changes -> 'last_imported_translation' IS NOT NULL")&.reverse&.first&.whodunnit
    User.find_by(id: u_id)&.name unless u_id.nil?
  end

  def published_by
    u_id = self.versions.where("object_changes -> 'last_published' IS NOT NULL")&.reverse&.first&.whodunnit
    User.find_by(id: u_id)&.name unless u_id.nil?
  end
 
  def deleted_from_archive_by
    u_id = self.versions.where("object_changes -> 'deleted_from_archive' IS NOT NULL")&.reverse&.first&.whodunnit
    User.find_by(id: u_id)&.name unless u_id.nil?
  end
 
  # Determins if page is a next generation page which supports scheduling
  def next_gen?
    return true if context_type == 'supports_schedules'

    false
  end

  # Excludes system activity
  def last_updated_by
    last_activity = page_activities.where.not(user: nil).last
    return 'None' if last_activity.nil?

    if last_activity.user.nil?
      'System'
    else
      last_activity.user.email
    end
  end

  def get_translations(user)
    locales = user.team.all_locales

    translationLocales = [{ title: 'Id', field: 'id', editable: 'never' }]
    translationLocales << { title: 'default', field: 'default' }

    locales.each do |locale|
      translationLocales << { title: locale, field: locale }
    end

    translationIds = []

    page_modules.each do |page_module|
      page_module.body.scan(/loc::([0-9]*)/) do
        translationIds << Regexp.last_match(1)
      end
    end
    translationsArray = []
    columns = []

    translations = PagesController.helpers.list_translations(translationIds) do |translations|
      translations.each do |translation|
        translationHash = {}
        translationLocalesAndValues = []
        translationHash['id'] = translation['id']

        translation['body'].each_with_index do |locale, _index|
          translationHash[locale[0]] = locale[1]
        end
        translationsArray << translationHash
      end
    end

    {
      translations: translationsArray,
      columns: translationLocales
    }
  end

  def get_publishing_locales
    publishingLocales = publishing_locales.sort_by(&:locale)
    approvedSites = []
    unapprovedSites = []
    publishingSites = {}
    publishingLocales.each do |pubLocale|
      # pubLocale is a country ID
      localesForSite = SettingService.get_locales_for_site(pubLocale.locale)
      publishingSites[pubLocale.locale] = {
        id: pubLocale.locale,
        name: pubLocale.name,
        locales: localesForSite
      }
      if !pubLocale.approver_id.nil?
        approvedSites << { id: pubLocale.locale, name: pubLocale.name, locales: localesForSite }
      else
        unapprovedSites << { id: pubLocale.locale, name: pubLocale.name, locales: localesForSite }
      end
    end
    [publishingLocales, publishingSites, approvedSites, unapprovedSites]
  end

  def country_approved?(site)
    result = publishing_locales.select { |pu| pu['locale'] == site['locale_id'] }
    return false if result.count == 0
    return true unless result.first.approver_id.nil?

    false
  end

  def thumb
    return 'error' if thumbnail.nil?
    return '' if thumbnail.attachment.nil?

    if !thumbnail.nil?
      variant = thumbnail.variant(resize_to_fill: [250, 250, { gravity: 'North' }])
      rails_representation_url(variant)
    else
      ''
    end
  end

  def safe_name
    name.gsub(/\s/, '_').gsub(/[^A-Za-z0-9\-_]+/, '')
  end

  # Determines if a country has already been added to the page
  def country_added?(site)
    result = publishing_locales.select { |pu| pu['locale'] == site['id'] }
    return false if result.count == 0

    true
  end

  def self.by_team(current_user)
    Page.where(team_id: current_user.team_id)
  end

  # returns an array of locale codes: [de-DE, fr-FR]
  def locale_codes
    country_groups.map(&:locale_codes).flatten.uniq
  end

  # Wraps the TranslationService
  def send_to_translation_validation
    active_modules = page_modules.order(rank: :asc)
    rendered_modules = active_modules.map { |f| f.body.to_s }
    service = TranslationService.new
    service.send_to_translation(
      page_id: id,
      body: rendered_modules.to_s,
      page_translation_status: 0 # Stale documents make the translation project return bad request
    ) do |error, document_id, new_translation_status|
      if error.nil?
        self.translation_status = new_translation_status
        self.translation_key = document_id
        yield nil if block_given?
      else
        puts 'error validing translation'
        yield error if block_given?
      end
    end
  end
end
