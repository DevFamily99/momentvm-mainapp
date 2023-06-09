require 'uri'
require 'net/http'
require 'json'
require 'request'
# Methods helping with publishing
module PublishHelper
  include AssetsHelper

  # Publishes a manifest content asset for new page type
  # Since we create a content asset for each PageModule,
  # we need one content asset which ties them together
  def publish_manifest_new_page(manifest_id, user_id)
    current_user = User.find(user_id)
    manifest = PublishingManifest.find(manifest_id)
    page = manifest.page
    page_modules = page.page_modules.order(rank: :asc)
    req = Request.new
    body = {
      modules: page_modules.map { |pm| sfcc_id(pm, manifest.page) },
      manifest: manifest.name,
      locales: manifest.locale_codes
    }
    body['page_title'] = page.title if page.title
    body['page_url'] = page.url if page.url
    body['page_description'] = page.description if page.description
    body['page_keywords'] = page.keywords if page.keywords
    req.send_request(
      url: ENV.fetch('RENDER_SERVICE_URL') + '/publish_manifest',
      header: {
        "Client-ID": current_user.team.client_id,
        "Client-Secret": current_user.team.client_secret,
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
    ) do |response_code, _response|
      event = PublishingEvent.new
      event.publishing_manifest = manifest
      event.message_obj = { "status_codes": [response_code] }
      event.category = 'publish_manifest'
      event.save
      ContentManagementSchema.subscriptions.trigger(:page_publishing_status, { page_id: manifest.page.id }, manifest)

      return response_code
    end
  end
end
