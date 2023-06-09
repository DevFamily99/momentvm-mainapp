module Publishing
  # Retrieves an array of image matches of the shape {  }
  # name: Stokke-Flexibath-Article-GalleryImages-07
  # file_ending: .jpg
  # variants:
  #   - name: large
  #     file_ending: .jpg
  #     url: /rails/active_storage/representations/eyJfcmFpbHMiOnsibW...
  #   - name: verylarge
  #     file_ending: .jpg
  class GetDynamicImages < Actor
    input :assets, allow_nil: false
    input :variant_settings, allow_nil: false

    output :images

    def call
      self.images = []
      assets.each do |image|
        # one variant
        self.images << {
          name: image.name,
          file_ending: image.file_ending,
          variants: image.variants(variant_settings)
        }
      end
    end
  end
end
