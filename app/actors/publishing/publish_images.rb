module Publishing
  # Publishes images to salesforce
  class PublishImages < Actor
    input :manifest, allow_nil: false

    def call
      image_search_result = Publishing::FindImageMatches.call(modules: manifest.page_modules).images
      grouped_result = image_search_result.group_by { |image_match| image_match['name'] } # Group by image
      all_variants_from_settings = SettingService.load_image_sizes_from_db(manifest.user.team)
      responses = []
      grouped_result.each do |name, variant_list|
        image = Asset.find_by name: name
        if image.nil?
          puts "Couldnt find image: #{name}"
          next
        end
        variant_list.each do |variant|
          variant_name = variant['variant_name']
          commands = all_variants_from_settings[variant_name]
          file_name = "#{name}__#{variant_name + image.file_ending}"
          responses << image.upload(file_name: file_name, variant_name: variant_name, commands: commands, publishing_target: manifest.publishing_target)
        end
      end
      Publishing::UpdateImageUploadPublishEvent.call(manifest: manifest, responses: responses)
      Publishing::BroadcastPublishingStatus.call(manifest: manifest)
    end
  end
end
