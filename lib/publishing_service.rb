require "uri"
require "net/http"
require 'micro_service'


###### D E P R E C A T E D
# TODO Remove
class PublishingService < MicroService
  # content_asset_document: Hash
  def publish(content_asset_document:, content_asset_id:, category_id:, instance:, context_type:, folder_assignments:, page_title:, page_description:, page_keywords:, page_url:, searchable:)
    uri = URI.parse("#{URL_PUBLISH_SERVICE}/api/publish-content/#{content_asset_id}/category/#{category_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    header = {
      "Content-Type" => "application/json",
      "Instance-URL" => "#{instance}",
      "Context-Type" => "#{context_type}"
    }

    if folder_assignments != nil
      header["Folder-Assignments"] = folder_assignments.join(',')
    end

    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.basic_auth USER_PUBLISH_SERVICE, PASSWORD_PUBLISH_SERVICE
    request_body = {
      c_body: content_asset_document
    }
    request_body[:page_keywords] = page_keywords if page_keywords
    request_body[:page_title] = page_title if page_title
    request_body[:page_url] = page_url if page_url
    request_body[:page_description] = page_description if page_description
    request_body[:searchableFlag] = { default: searchable } if searchable

    request.body = request_body.to_json.to_s
    response = http.request(request)
    if response.code == "200"
      self.body = response.body
      yield :no_errors
      return
    else
      error_message = JSON.parse(response.body)["message"]
      puts "!Error from PublishingService service: #{response.code}. #{error_message}"
      yield error_message
    end
  end


end
