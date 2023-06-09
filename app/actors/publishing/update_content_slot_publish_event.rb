module Publishing
  # Updates the `publish_content_slots` Publishing Event for a publishing manifest
  class UpdateContentSlotPublishEvent < Actor
    input :manifest, allow_nil: false
    input :site, allow_nil: false
    input :response, allow_nil: false

    output :content_slots_event

    def call
      response_body = response.body
      begin
        response_body = JSON.parse response.body
      rescue StandardError
        nil
      end
      fail!(error: 'Publishing Service is down') if response.code == '503'

      content_slots_event = manifest.content_slots_publishing
      event_message = content_slots_event.message
      event_status = content_slots_event.status
      if %w[200 201].include?(response.code)
        event_message[site.salesforce_id] = { status: 'success' }
        event_status = 'completed' if event_message.values.map { |m| m['status'] }.uniq.length == 1
      else
        event_message[site.salesforce_id] = { status: 'failed', error: response_body.dig('fault', 'message') }
        event_status = 'failed'
      end

      content_slots_event.update!(message: event_message, status: event_status)
      self.content_slots_event = content_slots_event
    end
  end
end
