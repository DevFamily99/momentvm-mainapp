# t.string "name"
# t.string "salesforce_id"
# t.bigint "team_id"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# t.index ["team_id"], name: "index_sites_on_team_id"

require 'request'

# Represents a Site from the Salesforce Api
class Site < ApplicationRecord
  belongs_to :team
  has_many :country_groups_sites, dependent: :destroy
  has_many :country_groups, through: :country_groups_sites
  has_and_belongs_to_many :publishing_manifests
  has_many :locales, dependent: :destroy

  def salesforce_locales(publishing_target_id)
    sites_req = Request.new
    sites_req.send_request(
      url: "#{ENV.fetch('RENDER_SERVICE_URL')}/salesforce",
      header: {
        'Target-Host':
          URI(
            team.publishing_targets.find(publishing_target_id)
              .publishing_url
          )
            .host,
        'Ressource-Path':
          '/s/-/dw/data/v19_1/sites/' + salesforce_id +
            '/locale_info/locales?select=(**)&count=500',
        'Client-ID': team.client_id,
        'Client-Secret': team.client_secret
      },
      options: {
        type: :get,
        json: true,
        username: ENV.fetch('RENDER_SERVICE_USERNAME'),
        password: ENV.fetch('RENDER_SERVICE_PASSWORD')
      }
    ) do |response_code, response|
      raise Errors::SalesforceBadResponse.new(response), 'bad response' unless response_code == 200

      return JSON.parse(response.body)['hits'] # .map{|site| site["id"]}
    end
  end
end
