module Types
  class SiteType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :salesforce_id, String, null: true
    field :locales, [LocaleType], null: true
  end
end
