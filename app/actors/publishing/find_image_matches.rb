module Publishing
  # Searches for images in the module body by rendering the modules on the render service
  # We return an object with structure { images: [ { name: raw_match: variant_name: } ]}
  class FindImageMatches < Actor
    input :modules, allow_nil: false

    output :images

    def call
      rendered_modules = []
      modules.each do |rendered_module|
        rendered_module.body = YAML.unsafe_load(rendered_module.body).to_json
        rendered_modules << rendered_module
      end
      nested_modules = modules.map(&:page_modules).flatten
      req = Request.new
      preview_body = {
        modules: rendered_modules,
        templates: modules.map(&:template),
        nestedModules: nested_modules, # didn't work with only this line
        nested_modules: nested_modules
      }
      req.send_request(
        url: "#{ENV.fetch('RENDER_SERVICE_URL')}/find_images",
        body: preview_body,
        options: {
          type: :post,
          json: true,
          username: ENV.fetch('RENDER_SERVICE_USERNAME'),
          password: ENV.fetch('RENDER_SERVICE_PASSWORD')
        }
      ) do |response_code, response|
        # fail!(error: 'Publishing service is down') if response_code == 503
        fail!(error: 'Renderer failed parsing images') unless response_code == 200

        self.images = JSON.parse(response.body)['images'] || []
      end
    end
  end
end
