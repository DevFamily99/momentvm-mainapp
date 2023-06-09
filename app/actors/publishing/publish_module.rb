module Publishing
  # Publishes a single page module
  class PublishModule < Actor
    input :manifest, allow_nil: false
    input :page_module, allow_nil: false
    input :images, default: []

    output :manifest

    def call
      page_module.body = YAML.unsafe_load(page_module.body).to_json
      req = Request.new
      req_body = {
        module: page_module,
        template: page_module.template,
        content_asset_name: page_module.sfcc_id(manifest),
        images: images,
        locales: manifest.locale_codes,
        webdav_path: manifest.publishing_target.webdav_path
      }
      req.send_request(
        url: "#{ENV.fetch('RENDER_SERVICE_URL')}/publish_modules",
        header: {
          "Client-ID": manifest.user.team.client_id,
          "Client-Secret": manifest.user.team.client_secret,
          "Target-Host": manifest.publishing_target.publishing_url,
          "Default-Library": manifest.publishing_target.default_library
        },
        body: req_body,
        options: {
          type: :post,
          json: true,
          username: ENV.fetch('RENDER_SERVICE_USERNAME'),
          password: ENV.fetch('RENDER_SERVICE_PASSWORD')
        }
      ) do |_response_code, response|
        Publishing::UpdateModulePublishEvent.call(manifest: manifest, page_module: page_module, response: response)
        Publishing::BroadcastPublishingStatus.call(manifest: manifest)
      end
    end
  end
end
