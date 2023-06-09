namespace :migrate do
  desc 'Adds a default team to all objects which up to this point do not have a team'
  task teams: :environment do
    create_team
    assign_users_to_teams
    assign_team_to_pages
    assign_team_to_settings
    assign_team_to_page_folder
    make_app_admin
    assign_team_to_asset_folders
    assign_team_to_templates
    create_publishing_targets(team: Team.first)
  end

  # Was neccessary to invalidate fields, new gem requires an iv and having one field
  # and not the other was a problem.
  # Remember to set the fields again after migrating
  task encryption: :environment do
    Team.all.each do |t|
      t.encrypted_client_id = nil
      t.encrypted_client_secret = nil
      t.save
    end

    PublishingTarget.all.each do |t|
      t.encrypted_webdav_username = nil
      t.encrypted_webdav_password = nil
      t.save
    end
  end

  task page_module_pages_migration: :environment do
    page_modules = PageModule.all
    page_modules.each do |mod|
      mod.pages << Page.find(mod.page_id)
      mod.save!
    end
  end

  task create_plans: :environment do
    Plan.all.destroy_all
    free_plan = Plan.new
    free_plan.name = 'Free Plan'
    free_plan.country_limit = 3
    free_plan.save

    pro_plan = Plan.new
    pro_plan.name = 'Pro Plan'
    pro_plan.country_limit = 99_999
    pro_plan.save!

    stokke = Team.find_by_name('STOKKE')
    stokke.plan = pro_plan
    stokke.save
  end

  task assign_plans: :environment do
    plan = Plan.find_by_name('Free Plan')
    Team.where(plan_id: nil).each do |team|
      team.plan = plan
      team.save
    end
  end

  task image_settings: :environment do
    Team.all.each do |team|
      setting = Setting.where(team: team, name: 'image-sizes').first
      new_body = {}
      next if setting.nil?
      next if setting.body.nil?

      body = YAML.load(setting.body)
      # puts body
      body.each do |setting_name, settings|
        new_commands = {}
        settings.each do |command, value|
          new_commands['resize_to_fit'] = value.split('x').map(&:to_i) if command == 'resize'
          new_commands['resize_to_fit'] = value if command == 'resize_to_fit'
          new_commands['saver'] = { quality: 75 } # default
          new_commands['saver'] = { quality: value } if command == 'quality'
        end
        new_body[setting_name] = new_commands
      end
      s_new = Setting.new(name: 'image-sizes')
      s_new.body = new_body.to_yaml
      s_new.team = setting.team
      setting.name = 'image-sizs-old'
      setting.save
      puts s_new.save
    end
  end

  task drop_instances: :environment do
    sql = 'drop table instances'
    ActiveRecord::Base.connection.execute(sql)
  end

  task screenshot_service: :environment do
    user = User.find_by_email('screenshot@momentvm.com')
    user.user_type = 'screenshot_bot'
    puts user.save
  end

  task set_show_setup_assistant: :environment do
    teams = Team.all
    teams.each do |team|
      team.show_setup_assistant = false
      team.save
    end
  end

  desc 'Unlink and copy modules used on multiple pages'
  task unlink_modules: :environment do
    page_modules = PageModule.joins(:pages).having("count('page_module_id')>1").group(:page_module_id).count
    page_modules.each do |key, _value|
      page_module = PageModule.find(key)
      page_module.pages.each_with_index do |page, i|
        next if i.zero?

        new_page_module = PageModule.new
        new_page_module.body = page_module.body
        new_page_module.rank = page_module.rank
        new_page_module.template = page_module.template
        new_page_module.save
        page.page_modules.delete(page_module)
        page.page_modules << new_page_module
      end
    end
  end

  def assign_team_to_templates
    team = Team.first
    Template.all.each do |s|
      s.team = team
      s.save
    end
    TemplateSchema.all.each do |s|
      s.team = team
      s.save
    end
  end

  def assign_team_to_page_folder
    team = Team.first
    PageFolder.all.each do |f|
      f.team = team
      f.save
    end
  end

  def make_app_admin
    admin = User.find_by_email('admin')
    admin.app_admin = true
    admin.save
  end

  def assign_team_to_settings
    team = Team.first
    Setting.all.each do |s|
      s.team = team
      s.save
    end
  end

  def assign_team_to_instances; end

  def assign_team_to_pages
    team = Team.first
    Page.all.each do |p|
      p.team = team
      p.save
    end
  end

  def create_team
    return if Team.all.count > 0

    team = Team.new
    team.owner_firstname = 'Test'
    team.owner_lastname = 'Test'
    team.owner_email = 'david.nassler@momentvm.com'
    team.name = 'STOKKE'
    team.approved = true
    team.save
  end

  def assign_users_to_teams
    team = Team.first
    User.all.each do |user|
      user.team = team
      user.save
    end
  end

  def assign_team_to_asset_folders
    team = Team.first
    AssetFolder.all.each do |af|
      af.team = team
      af.save
    end
  end

  def cleanup_page_archives
    oldArchiveFolders = PageFolder.where(name: 'Archive').where.not(id: 99)

    oldArchiveFolders.each { |folder| folder.pages.each(&:destroy) }
    oldArchiveFolders.each(&:destroy)
  end

  def create_publishing_targets(team:)
    # Instances there?
    if PublishingTarget.where(team: team).count != 0
      puts 'publishing target already created'
      return
    end
    stgInstance = PublishingTarget.create!(name: 'Staging',
                                           publishing_url: 'https://staging-web-stokke.demandware.net/s/Sites-Site/dw/data/v16_6',
                                           webdav_username: 'momentvm',
                                           webdav_password: '',
                                           webdav_path: 'https://staging-web-stokke.demandware.net/on/demandware.servlet/webdav/Sites/Libraries/StokkeSharedLibrary/default/cms_assets',
                                           preview_url: 'https://staging-web-stokke.demandware.net',
                                           team_id: team.id)

    devInstance = PublishingTarget.create!(name: 'Development',
                                           publishing_url: 'https://development-web-stokke.demandware.net/s/Sites-Site/dw/data/v16_6',
                                           webdav_username: 'momentvm',
                                           webdav_password: '',
                                           webdav_path: 'https://development-web-stokke.demandware.net/on/demandware.servlet/webdav/Sites/Libraries/StokkeSharedLibrary/default/cms_assets',
                                           preview_url: 'https://development-web-stokke.demandware.net',
                                           team_id: team.id)

    sandboxInstance = PublishingTarget.create!(name: 'Sandbox',
                                               publishing_url: 'https://dev02-web-stokke.demandware.net/s/Sites-Site/dw/data/v16_6',
                                               webdav_username: 'momentvm',
                                               webdav_password: '',
                                               webdav_path: 'https://dev02-web-stokke.demandware.net/on/demandware.servlet/webdav/Sites/Libraries/StokkeSharedLibrary/default/cms_assets',
                                               preview_url: 'https://dev02-web-stokke.demandware.net',
                                               team_id: team.id)
  end
end
