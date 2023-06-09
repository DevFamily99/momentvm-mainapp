module Types
  class CountryGroupType < BaseObject
    description 'CountryGroup'
    field :id, ID, null: true
    field :name, String, null: true
    field :description, String, null: true
    field :team_id, ID, null: true
    field :sites, [SiteType], null: true
    field :locales, [LocaleType], null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
