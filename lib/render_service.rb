require 'uri'
require 'net/http'
require 'micro_service'
require 'setting_service'

class RenderService < MicroService
  def render_page(_active_modules, _templates)
    locales = SettingService.load_from_db
    send_request(
      url: "#{ENV.fetch('RENDER_SERVICE_URL')}/render_page",
      # url: "http://0.0.0.0:5000/logger/log",
      body: {
        foo: 'bar'
        # modules: [{id: "foo"}],
        # templates: []
        # templates: templates,
        # locales: locales
      },
      options: {
        type: :post,
        ssl: true,
        username: ENV.fetch('RENDER_SERVICE_USERNAME'),
        password: ENV.fetch('RENDER_SERVICE_PASSWORD')
      }
    ) do |_response_code, response|
      yield response
    end
  end

  # Uses RenderService to render the template
  # error, page_modules
  def render_page_module(rendering_mode, page_module)
    module_body = page_module.body # module data
    yield "ERROR in #{page_module.rank}. Module body is nil", nil if module_body.nil?
    module_body = YAML.load(module_body)
    module_body = '' if page_module.body.nil?
    template_body = page_module.template.body # template code
    uri = URI.parse("#{ENV.fetch('RENDER_SERVICE_URL')}/render")
    puts "Render service url: #{ENV.fetch('RENDER_SERVICE_URL')}/render"
    # puts "Request for render service to #{uri} for key RENDER_SERVICE_URL"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    header = {
      'Content-Type' => 'application/json'
    }
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.basic_auth ENV.fetch('RENDER_SERVICE_USERNAME'), ENV.fetch('RENDER_SERVICE_PASSWORD')
    request_body = {
      module_body: module_body,
      template_body: template_body,
      rendering_mode: rendering_mode,
      page_module_id: page_module.id,
      page_module_rank: page_module.rank,
      template_name: page_module.template.name,
      template_id: page_module.template.id
    }
    request.body = request_body.to_json
    response = http.request(request)
    yield 'Unknown response code from RenderService', nil unless response.code == '200'
    self.body = response.body
    yield nil, response.body
    nil
  end
end
