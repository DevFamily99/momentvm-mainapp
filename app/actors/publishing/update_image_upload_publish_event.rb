module Publishing
  # Updates the `upload_assets` Publishing Event for a publishing manifest
  class UpdateImageUploadPublishEvent < Actor
    input :manifest, allow_nil: false
    input :responses, allow_nil: false

    output :module_event

    def call
      module_event = manifest.asset_upload
      codes_set = Set.new(responses.map { |res| res&.code })
      if codes_set.include? '401'
        module_event.update!(message: { WebDAV: { error: 'Credentials are invalid or expired' } }, status: 'failed')
        return
      end
      if codes_set.include? nil
        module_event.update!(message: { WebDAV: { error: 'Failed to upload all images, check if all images on the page are valid.' } }, status: 'failed')
        return
      end
      module_event.update!(status: 'completed')
    end
  end
end
