module Publishing
  # Create the publishing publishing manifest for a schedule
  class CreateScheduleManifest < Actor
    input :user, allow_nil: false
    input :publishing_target, allow_nil: false
    input :schedule, allow_nil: false

    output :manifest

    def call
      fail!(error: 'Page context is not set') if schedule.page.page_context.nil?
      fail!(error: 'Selected schedule does not have valid country groups') if schedule.country_groups.empty?
      fail!(error: 'Selected schedule any modules assigned to it') if schedule.valid_modules.empty?
      publish_images = schedule.page.publish_assets && FindImageMatches.call(modules: schedule.valid_modules).images.any?
      self.manifest = PublishingManifest.create!(
        page: schedule.page,
        publishing_target: publishing_target,
        user: user,
        sites: schedule.country_groups.map(&:sites).flatten,
        name: schedule.page.page_context.context.gsub(' ', '_'),
        schedule: schedule,
        publish_images: publish_images,
        progress_parts: schedule.valid_modules.count + schedule.country_groups.map(&:sites).flatten.count + (publish_images ? 1 : 0),
        locale_codes: schedule.locale_codes
      )
    end
  end
end
