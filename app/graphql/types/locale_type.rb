module Types
  class LocaleType < BaseObject
    field :id, ID, null: false
    field :code, String, null: false
    field :name, String, null: false
    field :display_name, String, null: false
    field :display_country, String, null: false
    field :display_language, String, null: false
  end
end