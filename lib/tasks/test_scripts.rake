require 'translation_service'

namespace :test_scripts do
  desc 'Test scripts for local development or prod verification'
  namespace :run do

    task find_translation: :environment do
      desc 'Find a translation using translation service'
      tr = TranslationService.new
      puts tr.get_translation(20154)
    end

    task check_module: :environment do
      pm = PageModule.find 408439181
      data = YAML.unsafe_load pm.body
      puts data.to_json
      hsh = JSON.parse(data.to_json).to_yaml
      puts hsh
    end

    task check_role: :environment do
      role = Role.find 60
      data = YAML.unsafe_load role.body
      puts data.to_json
      hsh = JSON.parse(data.to_json).to_yaml
      puts hsh
    end

    task check_page: :environment do
      desc "check a pages modules"
      p = Page.find 992942750
      puts p.name
      p.page_modules.each do |pm|
        puts pm.id
        # puts pm.body
        body_json = YAML.unsafe_load(pm.body).to_json
        body_yaml = JSON.parse(body_json).to_yaml
        puts body_yaml
      end
    end
  end
end
