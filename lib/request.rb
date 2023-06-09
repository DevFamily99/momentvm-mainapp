# Generic Request
# v1.2.0
require 'uri'
require 'net/http'

# Use like so:
# r = Request.new
# r.send_request(
#   url: "http://test.com"
# ) do |response_code, response|
#   puts response_code
# end
class Request
  # Yields resonse_code (int), response
  # Parameters besides url: are optional
  def send_request(url:, body: {}, header: {}, options: {})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    request = if options.key? :type
                case options[:type]
                when :put
                  Net::HTTP::Put.new(uri.request_uri, header)
                when :post
                  Net::HTTP::Post.new(uri.request_uri, header)
                when :patch
                  Net::HTTP::Patch.new(uri.request_uri, header)
                when :head
                  Net::HTTP::Head.new(uri.request_uri, header)
                else
                  Net::HTTP::Get.new(uri.request_uri, header)
                          end
              else
                # Default is GET
                Net::HTTP::Get.new(uri.request_uri, header)
              end

    request.basic_auth options[:username], options[:password] if options.key?(:username) && options.key?(:password)

    request.body = body unless body.empty?
    request.body = body.to_json.to_s unless body.class == String

    # SSL is taken from the environment
    http.use_ssl = Rails.configuration.force_ssl unless Rails.env.development?
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # options: json
    if options.key? :json
      request.add_field('Content-Type', 'application/json')
      request.add_field('Accept', 'application/json')
    end

    # Force SSL option
    http.use_ssl = true if options.key? :force_ssl
    # Force SSL option
    http.use_ssl = true if options.key? :ssl

    if options.key? :ssl_version
      http.ssl_version = :TLSv1_2 if options[:ssl_version] == :TLSv1_2
      http.use_ssl = true
    end

    # Error check
    puts 'Error: Specified a http url but SSL is set to true' if http.use_ssl? && url[/http\:/]

    if options.key? :verbose
      puts 'Method'
      puts request
      puts 'Body'
      puts request.body
      puts "Body is a #{request.body.class}"
      puts "Uses SSL: #{http.use_ssl?}"
      http.set_debug_output($stdout)
    end

    response = http.request(request)
    yield response.code.to_i, response
  end
end
