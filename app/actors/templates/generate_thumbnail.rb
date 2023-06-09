module Templates
  # Generate a thumbnail on the screenshot service and save the thumbnail
  class GenerateThumbnail < Actor
    require 'request'

    input :page_module
    input :page
    output :template

    def call
      req = Request.new
      req.send_request(
        url: "#{ENV.fetch('SCREENSHOT_SERVICE')}/templateThumb",
        body: {
          pageModuleId: page_module.id,
          pageId: page.id
        },
        options: {
          type: :post,
          json: true
        }
      ) do |_response_code, response|
        template = page_module.template
        decoded_file = Base64.decode64(JSON.parse(response.body)['image'])
        filename = 'image.png' # this will be used to create a tmpfile and also, while setting the filename to attachment
        tmp_file = Tempfile.new(filename) # This creates an in-memory file
        tmp_file.binmode # This helps writing the file in binary mode.
        tmp_file.write decoded_file
        tmp_file.rewind
        template.image.attach(io: tmp_file, filename: filename) # attach the created in-memory file, using the filename defined above
        tmp_file.unlink # deletes the temp file
      end
    end
  end
end
