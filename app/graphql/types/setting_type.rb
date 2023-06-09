module Types
  class SettingType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :body, String, null: false
  end
end
