module Publishing
  # Publishes a content slot configuration to sfcc
  class PublishContentSlot < Actor
    input :manifest, allow_nil: false
    input :site, allow_nil: false
    input :category, default: 'global'

    def call
      start_date = manifest.schedule.start_at
      start_date = start_date.iso8601 if start_date
      end_date = manifest.schedule.end_at
      end_date = end_date.iso8601 if end_date

      slot_config_name = "#{manifest.page.name}_#{manifest.schedule.id}"
      slot_config_name = CGI.escape slot_config_name.gsub(/\s/, '_')

      context = manifest.page.page_context

      req = Request.new
      headers = {
        'Target-Host': URI(manifest.publishing_target.publishing_url).host,
        'Client-ID': manifest.user.team.client_id,
        'Client-Secret': manifest.user.team.client_secret,
        'Ressource-Path': "/s/-/dw/data/v19_5/sites/#{site.salesforce_id}/slots/#{context.slot}/slot_configurations/#{slot_config_name}?context=#{category}"
      }
      body = {
        template: context.rendering_template,
        slot_content: {
          type: 'content_assets',
          content_asset_ids: manifest.page_modules.map { |pmodule| pmodule.sfcc_id(manifest) }
        },
        default: false,
        enabled: true,
        description: "Sent from MOMENTVM #{DateTime.now}. Page ID: #{manifest.page.id}",
        schedule: {
          start_date: start_date,
          end_date: end_date
        },
        customer_groups: manifest.schedule.customer_groups.map(&:name),
        configuration_id: manifest.schedule.id.to_s
      }
      req.send_request(
        url: "#{ENV.fetch('RENDER_SERVICE_URL')}/salesforce",
        header: headers,
        body: body,
        options: {
          type: :put,
          json: true,
          username: ENV.fetch('RENDER_SERVICE_USERNAME'),
          password: ENV.fetch('RENDER_SERVICE_PASSWORD')
        }
      ) do |_response_code, response|
        Publishing::UpdateContentSlotPublishEvent.call(manifest: manifest, site: site, response: response)
        Publishing::AssignContentSlotConfigToCampaign.call(manifest: manifest, site: site) if manifest.schedule.campaign_id.present?
        Publishing::BroadcastPublishingStatus.call(manifest: manifest)
      end
    end
  end
end
