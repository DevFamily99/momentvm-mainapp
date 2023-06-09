module Publishing
  # Create the publishing publishing manifest for a content asset
  class CreateContentAssetManifest < Actor
    input :user, allow_nil: false
    input :publishing_target, allow_nil: false
    input :page, allow_nil: false

    output :manifest

    def call
      fail!(error: 'Selected page does not have valid country groups') if page.country_groups.empty?
      fail!(error: 'Selected page does not have any modules') if page.page_modules.empty?
      fail!(error: 'Selected page does not have a set context') if page.context.empty?
      publish_images = page.publish_assets && FindImageMatches.call(modules: page.page_modules).images.any?

      self.manifest = PublishingManifest.create!(
        page: page,
        publishing_target: publishing_target,
        user: user,
        sites: page.country_groups.map(&:sites).flatten,
        name: page.context,
        publish_images: publish_images,
        progress_parts: page.page_modules.count + 1 + (publish_images ? 1 : 0),
        locale_codes: page.locale_codes
      )
    end
  end
end
