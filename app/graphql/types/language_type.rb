module Types
  class LanguageType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :code, String, null: false
  end
end