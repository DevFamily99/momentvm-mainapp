require 'parser'
require 'faker'
require 'rainbow/refinement'

namespace :db do
  require 'csv'
  using Rainbow
  task migrate_page_modules: :environment do
    desc "Remove parameters and hash with indifferent access from page modules"
    puts "Starting migration".green
    processed_pms = 0
    found_parameters = 0
    PageModule.all.each do |pm|
      if pm.body.match("!ruby/")
        found_parameters += 1 
      else
        next
      end
      body_json = YAML.unsafe_load(pm.body).to_json
      body_yaml = JSON.parse(body_json).to_yaml
      # body will not automatically be parsed so we neet to convert to yaml
      pm.update_column(:body, body_yaml)
      processed_pms += 1
    end
    puts "Processed #{processed_pms} modules".green
    puts "Found #{found_parameters} parameter signatures".yellow
  end
    
  # Migrating serialized body to actual attributes
  task migrate_skills: :environment do
    puts "starting migration of roles"
    count = 0
    skipped_ids = []
    Role.all.each do |role|
      # next if role.id != 2
      next if role.body.nil?
      next if role.raw_body.nil?
      next unless role.raw_body.match "!ruby/"
      # Workaround to get rid of the HashWithIndifferentAccess stuff
      body_json = YAML.unsafe_load(role.raw_body).to_json
      body_yaml = JSON.parse(body_json)
      # Dont update since we need the real parameters only, anyways
      # translation.update_column :body, body_yaml
      # puts "Body nil for role #{role.id}, skipping" if role.body.nil?
      skipped_ids << role.id if role.body.nil?
      # puts role.body
      obj = {}
      obj = YAML.unsafe_load(role.raw_body).deep_stringify_keys
      # puts obj
      # puts obj.key? "can_publish_pages"]
      role.can_create_pages = true if obj.key? "can_create_pages"
      role.can_edit_pages = true if obj.key? "can_edit_pages"
      role.can_approve_pages = true if obj.key? "can_approve_pages"
      role.can_publish_pages = true if obj.key? "can_publish_pages"
      role.can_see_advanced_menu = true if obj.key? "can_see_advanced_menu"
      role.can_edit_templates = true if obj.key? "can_edit_templates"
      role.can_see_language_preview = true if obj.key? "can_see_language_preview"
      role.can_see_country_preview = true if obj.key? "can_see_country_preview"
      role.can_unpublish_pages = true if obj.key? "can_unpublish_pages"
      role.can_edit_settings = true if obj.key? "can_edit_settings"
      role.can_see_settings = true if obj.key? "can_see_settings"
      role.can_edit_all_modules_by_default = true if obj.key? "can_edit_all_modules_by_default"
      role.can_edit_module_permissions = true if obj.key? "can_edit_module_permissions"
      role.can_copy_modules = true if obj.key? "can_copy_modules"
      role.can_duplicate_page = true if obj.key? "can_duplicate_page"
      worked = role.save
      puts "Role saving failed for role #{role.id}".red if worked == false
      puts role.errors.full_messages if worked == false
      count = count + 1
    end
    puts "Done. Migrated #{count} roles. #{Role.all.count} total roles."
    puts "Skipped: #{skipped_ids}"
  end

  task anonymize_users: :environment do
    count = 0
    User.all.each do |u|
      next if u.email == 'admin'
      next if u.email.include? 'momentvm.com'

      u.email = Faker::Internet.email
      u.password = '123123'
      u.password_confirmation = '123123'
      puts 'error saving user' unless u.save
      count += 1 if u.save
    end
    puts "Successfully anonymized #{count} users."
  end

  task assign_team_id_to_page_modules: :environment do
    PageModule.all.each do |pm|
      if pm.pages.any? && !pm.team_id
        pm.team_id = pm.pages.first.team_id
        pm.save!
      end
    end
  end

  desc 'Used for listing all the locale combinations for the editor-locales setting'
  task list_locales: :environment do
    user = Team.first.users.first
    groups = SettingService.get_named_locale_variants user
    list = []
    groups.each do |obj|
      list << obj[:locale]
    end
    list = list.sort_by(&:length)
    list.unshift 'default'
    list.uniq!

    puts list.to_yaml
  end

  task import_ui_schemas: :environment do
    count = 0
    not_found = 0
    csv_text = File.read(Rails.root.join('schemas.csv'))
    csv = CSV.parse(csv_text, headers: false)
    csv.each do |row|
      ts = TemplateSchema.find(row[0])
      next if ts.nil?

      ts.ui_schema = row[1].gsub('_x000D_', '')
      ts.save
      count += 1
    rescue StandardError => e
      not_found += 1
    end
    puts "Imported #{count} ui schemas. Not found: #{not_found}"
  end

  task generate_folder_slugs: :environment do
    asset_folders = AssetFolder.all
    asset_folders.each do |af|
      unless af.save
        af.name = af.name + '(1)'
        af.save
      end
    end
    page_folders = PageFolder.all
    page_folders.each do |pf|
      unless pf.save
        pf.name = pf.name + '(1)'
        pf.save
      end
    end
  end
  task clean_page_modules: :environment do
    page_modules = PageModule.all
    page_modules.each do |page_module|
      body = YAML.load(page_module.body)
      body = delete_deep_key(body, 'selected') if body
      page_module.body = body.as_json.to_yaml
      page_module.save!
    rescue StandardError => e
      p e.message
      p page_module.id
    end
  end

  def delete_deep_key(h, key)
    h.each_key do |k|
      if k == key
        p 'found key'
        h.delete(k)
      end
      h[k] = delete_deep_key(h[k], key) if h[k].instance_of?(Hash)
    end
    h
  end

  task migrate_templates_to_vapor_4: :environment do
    template_count = 0
    templates = Template.all
    templates.each do |template|
      parser = Parser.new
      parser.full_body = template.body
      parser.walk
      template.body = parser.processed_body
      p 'saved' if template.save
      template_count += 1
    rescue StandardError => e
      p e.message
      p template.id
    end
    p "Success. #{template_count} templates processed."
  end

  task migrate_classic_pages: :environment do
    pages = Page.all
    pages.each do |page|
      page.context_type = 'supports_schedules'
      p 'saved' if page.save!
    rescue StandardError => e
      p e.message
      p page.id
    end
    p 'Success.'
  end

  task generate_folder_paths: :environment do
    page_folders = PageFolder.all
    asset_folders = AssetFolder.all
    page_folders.each do |page_folder|
      page_folder.path = Folders::GenerateFolderPath.call(folder: page_folder).path
      page_folder.save!
    end
    asset_folders.each do |asset_folder|
      asset_folder.path = Folders::GenerateFolderPath.call(folder: asset_folder).path
      asset_folder.save!
    end
  end

  task clean_publishing_manifests: :environment do
    PublishingManifest.destroy_all
  end

  task clean_country_group_locales: :environment do
    CountryGroupsLocale.destroy_all
    CountryGroup.all.each do |cg|
      cg.sites.each do |site|
        site.locales.each do |locale|
          cg.locales << locale
        end
      end
    end
  end
end
