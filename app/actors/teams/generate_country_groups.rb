module Teams
  # Generate demo countries and country group
  class GenerateCountryGroups < Actor
    input :team, allow_nil: false

    def call
      us = Site.find_or_create_by(team: team, name: 'United States', salesforce_id: 'US')
      us.locales << Locale.find_or_create_by(code: 'en-US', name: 'English (United States)', display_language: 'English', display_name: 'English (United States)', site: us)
      us.locales << Locale.find_or_create_by(code: 'es-US', name: 'Spanish (United States)', display_language: 'Spanish', display_name: 'Spanish (United States)', site: us)
      CountryGroup.find_or_create_by(name: 'Demo', description: 'A demo country group', team: team)
    end

    def rollback
      team.country_groups.destroy_all
      team.sites.destroy_all
    end
  end
end
