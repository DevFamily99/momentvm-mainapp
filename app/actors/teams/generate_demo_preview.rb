module Teams
    # Generate a demo page preview
    class GenerateDemoPreview < Actor
      input :pageId, allow_nil: false
  
      require 'request'
       
      def call
        req = Request.new
        req.send_request(
            url: "#{ENV.fetch('SCREENSHOT_SERVICE_KEY')}/screenshotDemoPage",
            body: {
            pageId: pageId
            },
            options: {
            type: :get,
            json: true
            }
        ) do |_response_code, response|
            puts response
        end
      end
    end
  end
  