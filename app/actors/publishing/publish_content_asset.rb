module Publishing
  # Publishes a pages contents as a content asset to the salesforce api
  class PublishContentAsset < Actor
    play CreateContentAssetManifest, CreatePublishingEvents, PublishModules, PublishManifest
    play PublishImages, if: ->(result) { result.manifest.publish_images }
    play AssignContentAssetToFolder, if: ->(result) { result.manifest.page.publishing_folder.present? }
  end
end
