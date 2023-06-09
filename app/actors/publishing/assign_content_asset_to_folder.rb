require 'request'

module Publishing
  # Assigns a published manifests content asset to a library folder on Salesforce
  class AssignContentAssetToFolder < Actor
    input :manifest, allow_nil: false

    def call
      req = Request.new
      headers = {
        'Target-Host': URI(manifest.publishing_target.publishing_url).host,
        'Client-ID': manifest.user.team.client_id,
        'Client-Secret': manifest.user.team.client_secret,
        'Ressource-Path': "/s/-/dw/data/v21_6/libraries/#{manifest.publishing_target.default_library}/folder_assignments/#{manifest.name}/#{manifest.page.publishing_folder}"
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
      ) do |response_code, response|
        response_body = response.body.empty? ? '' : JSON.parse(response.body)
        Publishing::UpdateManifestPublishEvent.call(manifest: manifest, response_code: response_code, response_body: response_body)
      end
    end
  end
end
