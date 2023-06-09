# frozen_string_literal: true

module Mutations
  class CreateCountryGroup < GraphQL::Schema::RelayClassicMutation
    field :country_group, Types::CountryGroupType, null: false

    argument :name, String, required: true
    argument :description, String, required: false
    argument :site_ids, [String], required: true
    argument :locale_ids, [String], required: true

    def resolve(name:, description:, site_ids:,  locale_ids: nil)
      puts 'create country group!'
      current_user = context[:current_user]
      country_group = CountryGroup.new(name: name, description: description, team: current_user.team)
      country_group.sites << Site.find(site_ids)
      country_group.locales << Locale.find(locale_ids)
      if country_group.save
        {
          country_group: country_group
        }
      else
        p country_group.errors[:name]
        errors_json = {}
        country_group.errors.each_key do |key|
          errors_json[key] = country_group.errors[key]
        end
        raise GraphQL::ExecutionError, errors_json.to_json
      end
     end
  end
end
