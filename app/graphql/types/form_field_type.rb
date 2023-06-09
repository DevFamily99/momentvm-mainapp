module Types
  class FormFieldType < BaseObject
    field :name, String, null: false
    field :type, String, null: false
    field :value, String, null: true
    field :localized, Boolean, null: false
  end
end