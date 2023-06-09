# Methods helping with publishing assets
require 'request'
module AssetsHelper
  # Performs a render pass to retrieve all needed images
  def find_images(active_modules, all_templates, team)
    assets = []
    dynamic_image_matches = find_images_matches(active_modules, all_templates)
    # Flatten so we can pass it to ActiveRecord
    if dynamic_image_matches
      flat_dynamic_images = dynamic_image_matches.map { |di| di['name'] }
      assets = Asset.where(name: flat_dynamic_images)
    end
    # return a list of assets with its dynamic variants
    # We only want the image urls for the variants that were requested
    dynamic_images_from(assets, team.image_settings) # asset_helper
  end

  # Retrieves an array of image matches of the shape {  }
  # name: Stokke-Flexibath-Article-GalleryImages-07
  # file_ending: .jpg
  # variants:
  #   - name: large
  #     file_ending: .jpg
  #     url: /rails/active_storage/representations/eyJfcmFpbHMiOnsibW...
  #   - name: verylarge
  #     file_ending: .jpg
  def dynamic_images_from(assets, variant_settings)
    images = []
    assets.each do |image|
      # one variant
      images << {
        name: image.name,
        file_ending: image.file_ending,
        variants: image.variants(variant_settings)
      }
    end
    images
  end

  # You probably want to use find_images as a more high level method
  # We return an object with structure { images: [ { name: raw_match: variant_name: } ]}
  def find_images_matches(active_modules, all_templates)
    rendered_modules = []
    active_modules.each do |rendered_module|
      rendered_module.body = YAML.unsafe_load(rendered_module.body).to_json
      rendered_modules << rendered_module
    end
    nested_modules = active_modules.map(&:page_modules).flatten
    req = Request.new
    preview_body = {
      modules: rendered_modules,
      templates: all_templates,
      nestedModules: nested_modules
    }
    req.send_request(
      url: ENV.fetch('RENDER_SERVICE_URL') + '/find_images',
      body: preview_body,
      options: {
        type: :post,
        json: true,
        username: ENV.fetch('RENDER_SERVICE_USERNAME'),
        password: ENV.fetch('RENDER_SERVICE_PASSWORD')
      }
    ) do |response_code, response|
      if response_code == 200
        return JSON.parse(response.body)['images']
      else
        puts "Error in :find_images_matches from render service (#{response_code})"
        return nil
      end
    end
  end

  # Uploads images to SFCC WebDAV
  # Takes its information from a PublishingManifest
  def upload_assets(manifest_id, page_id, publishing_target_id, team_id)
    manifest = PublishingManifest.find(manifest_id)
    puts ':upload_assets'
    # tr = TokenRequest.new
    # token = tr.get_token(team: Team.find(team_id))
    page = Page.find(page_id)
    publishing_target = PublishingTarget.find(publishing_target_id)
    team = Team.find(team_id)

    all_templates = Template.where(id: page.page_modules.pluck(:template_id))
    active_modules = page.page_modules.order(rank: :asc)
    image_search_result = find_images_matches(active_modules, all_templates)
    grouped_result = image_search_result.group_by { |image_match| image_match['name'] } # Group by image
    all_variants_from_settings = SettingService.load_image_sizes_from_db(team)
    upload_result_codes = []
    grouped_result.each do |name, variant_list|
      image = Asset.find_by name: name
      if image.nil?
        puts "Couldnt find image: #{name}"
        next
      end
      variant_list.each do |variant|
        variant_name = variant['variant_name']
        commands = all_variants_from_settings[variant_name]
        file_name = name + '__' + variant_name + image.file_ending
        upload_result_codes << image.upload(file_name: file_name, variant_name: variant_name, commands: commands, publishing_target: publishing_target)
      end
    end
    event = PublishingEvent.new
    event.publishing_manifest = manifest
    event.message_obj = { "status_codes": upload_result_codes }
    event.category = 'upload_assets'
    event.save
    if manifest.schedule_id
      ContentManagementSchema.subscriptions.trigger(:schedule_publishing_status, { schedule_id: manifest.schedule.id }, manifest)
    else
      ContentManagementSchema.subscriptions.trigger(:page_publishing_status, { page_id: manifest.page.id }, manifest)
    end
    upload_result_codes
  end
end
