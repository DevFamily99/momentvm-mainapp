module Publishing
  # Updates the `publish_manifest` Publishing Event for a publishing manifest
  class UpdateManifestPublishEvent < Actor
    input :manifest, allow_nil: false
    input :response_code, allow_nil: false
    input :response_body, allow_nil: false

    output :module_event

    def call
      manifest_publishing = manifest.manifest_publishing
      event_message = manifest_publishing.message
      if [200, 201].include?(response_code)
        event_status = 'completed'
        event_message['manifest'] = { status: 'success' }
      else
        event_status = 'failed'
        event_message['manifest'] = { status: 'failed', error: response_body['reason'],
                                      code: response_code, full_response: response_body }
      end
      manifest_publishing.update!(message: event_message, status: event_status)
    end
  end
end
