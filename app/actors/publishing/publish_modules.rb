module Publishing
  # Publishes a publishing manifests modules
  class PublishModules < Actor
    input :manifest, allow_nil: false

    output :manifest

    def call
      image_search_results = FindImageMatches.call(modules: manifest.page_modules).images
      images = Asset.where(name: image_search_results.pluck('name'))
      processed_images = GetDynamicImages.call(assets: images, variant_settings: manifest.user.team.image_settings).images
      page_modules = manifest.page.page_modules.order(rank: :asc)
      page_modules.each do |page_module|
        PublishModule.call(manifest: manifest, page_module: page_module, images: processed_images)
      end
    end
  end
end
