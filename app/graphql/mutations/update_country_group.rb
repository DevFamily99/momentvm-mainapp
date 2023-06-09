# frozen_string_literal: true

module Mutations
  class UpdateCountryGroup < GraphQL::Schema::RelayClassicMutation
    field :countryGroup, Types::CountryGroupType, null: true

    argument :id, ID, required: true
    argument :name, String, required: false
    argument :description, String, required: false
    argument :site_ids, [String], required: true
    argument :locale_ids, [String], required: true

    def resolve(id:, name: nil, description: nil, site_ids: nil, locale_ids: nil)
      country_group = CountryGroup.find(id)
      country_group.name = name if name
      country_group.description = description if description
      country_group.sites = []
      country_group.sites << Site.find(site_ids)
      country_group.locales = []
      country_group.locales << Locale.find(locale_ids)
      if country_group.save!
        {
          country_group: country_group
        }
      else
        errors_json = {}
        country_group.errors.each_key do |key|
          errors_json[key] = country_group.errors[key]
        end
        raise GraphQL::ExecutionError, errors_json.to_json
      end
    end
  end
end
