module Publishing
  # Publishes a publishing manifests modules
  class PublishManifest < Actor
    input :manifest, allow_nil: false

    output :manifest

    def call
      page = manifest.page
      page_modules = page.page_modules.order(rank: :asc)
      req = Request.new
      body = {
        modules: page_modules.map { |pm| pm.sfcc_id(manifest) },
        manifest: manifest.name,
        locales: manifest.locale_codes
      }
      body['page_title'] = page.title if page.title
      body['page_url'] = page.url if page.url
      body['page_description'] = page.description if page.description
      body['page_keywords'] = page.keywords if page.keywords
      req.send_request(
        url: "#{ENV.fetch('RENDER_SERVICE_URL')}/publish_manifest",
        header: {
          "Client-ID": manifest.user.team.client_id,
          "Client-Secret": manifest.user.team.client_secret,
          "Target-Host": manifest.publishing_target.publishing_url,
          "Default-Library": manifest.publishing_target.default_library
        },
        body: body,
        options: {
          type: :post,
          json: true,
          username: ENV.fetch('RENDER_SERVICE_USERNAME'),
          password: ENV.fetch('RENDER_SERVICE_PASSWORD')
        }
      ) do |response_code, response|
        response_body = response.body.empty? ? '' : JSON.parse(response.body)
        Publishing::UpdateManifestPublishEvent.call(manifest: manifest, response_code: response_code, response_body: response_body)
        Publishing::BroadcastPublishingStatus.call(manifest: manifest)
      end
    end
  end
end
