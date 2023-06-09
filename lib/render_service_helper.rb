require 'request'

class RenderServiceHelper < Request
  def find_images_matches(active_modules, all_templates)
    active_modules_json = active_modules.each do |content_module|
      content_module.body = YAML.load(content_module.body).to_json
    end
    preview_body = {
      modules: active_modules_json,
      templates: all_templates
    }
    send_request(
      url: ENV.fetch('RENDER_SERVICE_URL') + '/find_images',
      body: preview_body,
      options: {
        type: :post,
        json: true,
        username: ENV.fetch('RENDER_SERVICE_USERNAME'),
        password: ENV.fetch('RENDER_SERVICE_PASSWORD')
      }
    ) do |response_code, response|
      if response_code == 200
        return JSON.parse(response.body)['images']
      else
        puts 'Error in :find_images_matches from render service'
        return nil
      end
    end
  end
end
