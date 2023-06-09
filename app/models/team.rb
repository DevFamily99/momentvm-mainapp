require 'setting_service'
require 'request'

class Team < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  attr_encrypted :client_id, key: Rails.application.credentials.dig(:attr_enc_key)
  attr_encrypted :client_secret, key: Rails.application.credentials.dig(:attr_enc_key)

  has_many :publishing_targets, dependent: :destroy
  has_many :page_contexts, dependent: :destroy
  has_many :settings, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :pages, dependent: :destroy
  has_many :assets, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :template_schemas, dependent: :destroy
  has_many :country_groups, dependent: :destroy
  has_many :customer_groups, dependent: :destroy
  has_many :sites, dependent: :destroy
  has_many :pages, dependent: :destroy
  has_many :page_modules, dependent: :destroy
  has_many :page_folders, dependent: :destroy
  has_many :asset_folders, dependent: :destroy
  belongs_to :plan

  validates :name, uniqueness: true, presence: true
  validates :initials, format: {
    with: /\A[a-z0-9\-_]*\z/i, message: 'Only underscore allowed'
  }
  validates :owner_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :owner_email, uniqueness: true
  validates :owner_firstname, presence: true
  validates :owner_lastname, presence: true
  # validate :unique_user_email

  def should_generate_new_friendly_id?
    super || name_changed?
  end

  def unique_user_email
    errors.add(:owner_email, 'already taken') if User.where(email: owner_email).any?
  end

  def image_settings
    SettingService.load_image_sizes_from_db(self)
  end

  # returns an array of locale codes
  # taken from the team imported SFCC sites
  def all_locales
    locales = sites.includes(:locales).map do |site|
      site.locales.map(&:code)
    end
    locales = locales.flatten.uniq.sort
    locales.delete('default')
    locales
  end

  def salesforce_sites(publishing_target_id)
    sites_req = Request.new
    sites_req.send_request(
      url: "#{ENV.fetch('RENDER_SERVICE_URL')}/salesforce",
      header: {
        'Target-Host':
          URI(
            publishing_targets.find(publishing_target_id)
              .publishing_url
          )
            .host,
        'Ressource-Path': '/s/-/dw/data/v19_1/sites?select=(**)',
        'Client-ID': client_id,
        'Client-Secret': client_secret
      },
      options: {
        type: :get,
        json: true,
        username: ENV.fetch('RENDER_SERVICE_USERNAME'),
        password: ENV.fetch('RENDER_SERVICE_PASSWORD')
      }
    ) do |response_code, response|
      raise Errors::SalesforceBadResponse.new(response), 'bad response' unless response_code == 200

      return JSON.parse(response.body)['data'] # .map{|site| site["id"]}
    end
  end
end
