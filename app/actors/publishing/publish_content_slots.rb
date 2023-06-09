module Publishing
  # Publishes all content slots of a schedule
  class PublishContentSlots < Actor
    input :manifest, allow_nil: false

    def call
      # make a content slot on each site in the schedule
      manifest.sites.each do |site|
        page_category = manifest.page.category
        page_context = manifest.page.page_context

        if page_context.category?
          if page_category.split(', ').length > 1
            # publish to multiple categories
            page_category.split(', ').each do |category_id|
              PublishContentSlot.call(manifest: manifest, site: site, category: "category=#{category_id}")
            end
          else
            PublishContentSlot.call(manifest: manifest, site: site, category: "category=#{page_category}")
          end
        elsif page_context.folder?
          PublishContentSlot.call(manifest: manifest, site: site, category: "folder=#{page_category}")
        else
          PublishContentSlot.call(manifest: manifest, site: site)
        end
      end
    end
  end
end
