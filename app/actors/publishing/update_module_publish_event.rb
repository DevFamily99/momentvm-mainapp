module Publishing
  # Updates the `publish_modules` Publishing Event for a publishing manifest
  class UpdateModulePublishEvent < Actor
    input :manifest, allow_nil: false
    input :page_module, allow_nil: false
    input :response, allow_nil: false

    output :module_event

    def call
      response_body = response.body
      begin
        response_body = JSON.parse response.body
      rescue StandardError
        nil
      end
      fail!(error: 'Publishing Service is down') if response.code == '503'

      module_event = manifest.module_publishing
      event_message = module_event.message
      event_status = module_event.status
      if %w[200 201].include?(response.code)
        event_message[page_module.id] = { status: 'success', template: page_module.template_name }
        event_status = 'completed' if event_message.values.map { |m| m['status'] }.uniq.length == 1
      else
        event_message[page_module.id] = { status: 'failed', template: page_module.template_name, error: response_body['reason'],
                                          code: response.code, full_response: response_body }
        event_status = 'failed'
      end

      module_event.update!(message: event_message, status: event_status)
    end
  end
end
