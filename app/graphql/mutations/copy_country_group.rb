# frozen_string_literal: true

module Mutations
  # Copy an existing country group
  class CopyCountryGroup < GraphQL::Schema::RelayClassicMutation
    field :country_group, Types::CountryGroupType, null: false

    argument :id, ID, required: true

    def resolve(id:)
      country_group = CountryGroup.find(id)
      new_country_group = CountryGroup.create!(
        name: "#{country_group.name} (Copy)",
        description: country_group.description,
        team: country_group.team
      )
      country_group.sites.each do |site|
        new_country_group.sites << site
      end
      country_group.locales.each do |locale|
        new_country_group.locales << locale
      end

      { country_group: new_country_group }
    end
  end
end
