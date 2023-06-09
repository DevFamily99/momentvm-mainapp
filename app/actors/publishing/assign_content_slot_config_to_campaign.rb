require 'request'

module Publishing
  # Assigns a content slot configuration to a campaign on salesforce
  # Salesforce docs:
  # https://documentation.b2c.commercecloud.salesforce.com/DOC1/topic/com.demandware.dochelp/OCAPI/current/data/Resources/Campaigns.html#id-786531233__id-1675198153
  class AssignContentSlotConfigToCampaign < Actor
    input :manifest, allow_nil: false
    input :site, allow_nil: false

    def call
      context = manifest.page.page_context
      category_context = context.context_type == 'category' ? "category=#{manifest.page.category}" : 'global'
      slot_config_name = "#{manifest.page.name}_#{manifest.schedule.id}"
      slot_config_name = CGI.escape slot_config_name.gsub(/\s/, '_')
      slot_config_id = manifest.schedule.id.to_s
      campaign_id = manifest.schedule.campaign_id

      req = Request.new
      headers = {
        'Target-Host': URI(manifest.publishing_target.publishing_url).host,
        'Client-ID': manifest.user.team.client_id,
        'Client-Secret': manifest.user.team.client_secret,
        'Ressource-Path': "/s/-/dw/data/v21_6/sites/#{site.salesforce_id}/campaigns/#{campaign_id}/slot_configurations/#{slot_config_name}/#{slot_config_id}?context=#{category_context}"
      }

      req.send_request(
        url: "#{ENV.fetch('RENDER_SERVICE_URL')}/salesforce",
        header: headers,
        options: {
          type: :put,
          json: true,
          username: ENV.fetch('RENDER_SERVICE_USERNAME'),
          password: ENV.fetch('RENDER_SERVICE_PASSWORD')
        }
      ) do |_response_code, response|
        Publishing::UpdateContentSlotPublishEvent.call(manifest: manifest, site: site, response: response)
      end
    end
  end
end
