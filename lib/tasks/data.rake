require 'setting_service'

namespace :countries do
  desc 'TODO'
  namespace :from do
    task settings: :environment do
      desc 'Generate Countries and a sample Country Group from the SettingService'
      countries_from_settings
      create_country_groups
      puts 'done'
    end
  end
end
