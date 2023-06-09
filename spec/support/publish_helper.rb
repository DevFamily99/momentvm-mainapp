# frozen_string_literal: true

# Mocks requests to the publishing service
module PublishHelper
  def stub_publish_module_success(manifest:, page_module:)
    page_module.body = YAML.load(page_module.body).to_json
    stub_request(:post, "#{ENV.fetch('RENDER_SERVICE_URL')}/publish_modules")
      .with(
        body: {
          module: page_module.as_json,
          template: page_module.template.as_json,
          content_asset_name: page_module.sfcc_id(manifest),
          images: [],
          locales: manifest.locale_codes,
          webdav_path: manifest.publishing_target.webdav_path
        },
        headers: {
          content_type: 'application/json',
          "Client-ID": manifest.user.team.client_id,
          "Client-Secret": manifest.user.team.client_secret,
          "Target-Host": manifest.publishing_target.publishing_url,
          "Default-Library": manifest.publishing_target.default_library
        }
      )
      .to_return(status: 200)
  end

  def stub_publish_module_failure(manifest:, page_module:)
    page_module.body = YAML.load(page_module.body).to_json
    stub_request(:post, "#{ENV.fetch('RENDER_SERVICE_URL')}/publish_modules")
      .with(
        body: {
          module: page_module.as_json,
          template: page_module.template.as_json,
          content_asset_name: page_module.sfcc_id(manifest),
          images: [],
          locales: manifest.locale_codes,
          webdav_path: manifest.publishing_target.webdav_path
        },
        headers: {
          content_type: 'application/json',
          "Client-ID": manifest.user.team.client_id,
          "Client-Secret": manifest.user.team.client_secret,
          "Target-Host": manifest.publishing_target.publishing_url,
          "Default-Library": manifest.publishing_target.default_library
        }
      )
      .to_return(status: 400)
  end

  def stub_find_images_success(page_modules:)
    rendered_modules = []
    page_modules.each do |rendered_module|
      rendered_module.body = YAML.load(rendered_module.body).to_json
      rendered_modules << rendered_module
    end
    stub_request(:post, "#{ENV.fetch('RENDER_SERVICE_URL')}/find_images")
      .with(
        body: {
          modules: rendered_modules.as_json,
          templates: page_modules.map(&:template).as_json
        }
      )
      .to_return(status: 200, body: { images: [{ name: 'image', raw_match: 'image-file-name', variant_name: 'image200x800' }] }.to_json)
  end

  def stub_publish_content_slot_success(manifest:, site:)
    category_context = manifest.page.page_context.context_type == 'category' ? "category=#{manifest.page.category}" : 'global'
    slot_config_name = "#{manifest.page.name}_#{manifest.schedule.id}"
    slot_config_name = CGI.escape slot_config_name.gsub(/\s/, '_')
    stub_request(:put, "#{ENV.fetch('RENDER_SERVICE_URL')}/salesforce")
      .with(
        body: {
          template: manifest.page.page_context.rendering_template,
          slot_content: {
            type: 'content_assets',
            content_asset_ids: manifest.page_modules.map { |pmodule| pmodule.sfcc_id(manifest) }
          },
          default: false,
          enabled: true,
          description: "Sent from MOMENTVM #{DateTime.now}. Page ID: #{manifest.page.id}",
          schedule: {
            start_date: manifest.schedule.start_at.iso8601,
            end_date: manifest.schedule.end_at.iso8601
          },
          customer_groups: manifest.schedule.customer_groups.map(&:name),
          configuration_id: manifest.schedule.id.to_s
        }.to_json,
        headers: {
          content_type: 'application/json',
          "Client-ID": manifest.user.team.client_id,
          "Client-Secret": manifest.user.team.client_secret,
          'Ressource-Path': "/s/-/dw/data/v19_5/sites/#{site.salesforce_id}/slots/#{manifest.page.page_context.slot}/slot_configurations/#{slot_config_name}?context=#{category_context}"
        },
        basic_auth: [ENV.fetch('RENDER_SERVICE_USERNAME'), ENV.fetch('RENDER_SERVICE_PASSWORD')]
      )
      .to_return(status: 200, body: '')
  end

  def stub_publish_content_slot_failure(manifest:, site:)
    category_context = manifest.page.page_context.context_type == 'category' ? "category=#{manifest.page.category}" : 'global'
    slot_config_name = "#{manifest.page.name}_#{manifest.schedule.id}"
    slot_config_name = CGI.escape slot_config_name.gsub(/\s/, '_')
    stub_request(:put, "#{ENV.fetch('RENDER_SERVICE_URL')}/salesforce")
      .with(
        body: {
          template: manifest.page.page_context.rendering_template,
          slot_content: {
            type: 'content_assets',
            content_asset_ids: manifest.page_modules.map { |pmodule| pmodule.sfcc_id(manifest) }
          },
          default: false,
          enabled: true,
          description: "Sent from MOMENTVM #{DateTime.now}. Page ID: #{manifest.page.id}",
          schedule: {
            start_date: manifest.schedule.start_at.iso8601,
            end_date: manifest.schedule.end_at.iso8601
          },
          customer_groups: manifest.schedule.customer_groups.map(&:name),
          configuration_id: manifest.schedule.id.to_s
        }.to_json,
        headers: {
          content_type: 'application/json',
          "Client-ID": manifest.user.team.client_id,
          "Client-Secret": manifest.user.team.client_secret,
          'Ressource-Path': "/s/-/dw/data/v19_5/sites/#{site.salesforce_id}/slots/#{manifest.page.page_context.slot}/slot_configurations/#{slot_config_name}?context=#{category_context}"
        },
        basic_auth: [ENV.fetch('RENDER_SERVICE_USERNAME'), ENV.fetch('RENDER_SERVICE_PASSWORD')]
      )
      .to_return(status: 400, body: { 'fault' => { 'message' => 'Bad config' } }.to_json)
  end

  def stub_find_images_failure(page_modules:)
    rendered_modules = []
    page_modules.each do |rendered_module|
      rendered_module.body = YAML.load(rendered_module.body).to_json
      rendered_modules << rendered_module
    end
    stub_request(:post, "#{ENV.fetch('RENDER_SERVICE_URL')}/find_images")
      .with(
        body: {
          modules: rendered_modules.as_json,
          templates: page_modules.map(&:template).as_json
        }
      )
      .to_return(status: 500)
  end
end
