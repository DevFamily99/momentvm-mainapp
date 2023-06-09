require 'uri'
require 'net/http'
require 'micro_service'

# Loads the html wrapper of the target website for live editor
class ProxyService < MicroService
  def get_page_cached(url, selector)
    md5_hash = Digest::MD5.base64digest(url + selector)
    Rails.cache.fetch(
      ['page_wrapper_cache', md5_hash],
      expires_in: 12.hours
    ) do
      get_page(url, selector) do |_error, response|
        return response
      end
    end
  end

  # Yields error, html response
  def get_page(url, selector)
    req = Request.new
    req.send_request(
      url: "#{Rails.configuration.proxy_service[:url]}/getpage",
      options: {
        type: :get,
        username: Rails.configuration.proxy_service[:username],
        password: Rails.configuration.proxy_service[:password]
      },
      header: {
        targetURL: url,
        selector: selector
      }
    ) do |_response_code, response|
      unless response.code == '200'
        puts 'error :get_page reponse not 200 from proxy service'
        yield 'Response code not 200', nil
      end
      yield nil, response.body.force_encoding('UTF-8')
    end
  end
end
