module Teams
  # Generate demo page modules for a page
  class GenerateDemoPageModules < Actor
    input :page, allow_nil: false
    input :team, allow_nil: false

    def call
      demo_modules = YAML.load_file('spec/fixtures/demo_page_modules.yml')
      demo_modules.each do |data|
        demo_module = data[1]
        body = demo_module['body']
        replace_text = []

        # Generate localizations
        body.scan(/loc::(.*?)\n/) { replace_text << Regexp.last_match(1).strip }
        ts = TranslationService.new
        replace_text.each do |text|
          ts.new_translation({ default: text }, team.users.first) do |translation_id, _error|
            body = body.gsub(text, translation_id.to_s) if translation_id && !text.empty?
          end
        end

        # Generate images
        images = []
        body.scan(/image:(.*?)\n/) { images << Regexp.last_match(1).strip }
        images.each do |img|
          next unless img != ''

          file = img + '.jpg'

          file = File.open(Rails.root.join('spec/fixtures/images/', file), 'r')
          asset = Asset.find_by(name: img, team_id: team.id)
          asset = Asset.new(name: img, team_id: team.id) unless asset.present?
          asset.image.attach(io: file, filename: img, content_type: 'image/jpeg') unless asset.present?

          root_folder = AssetFolder.where(team: team, asset_folder_id: nil).first.id
          asset.asset_folder_id = root_folder

          asset.save!
        end

        page_module =
          PageModule.find_or_create_by!(
            template: Template.where(name: demo_module['template'], team_id: team.id).first,
            body: body,
            rank: demo_module['rank'],
            team_id: team.id
          )
        page.page_modules << page_module
      end
    end
  end
end
