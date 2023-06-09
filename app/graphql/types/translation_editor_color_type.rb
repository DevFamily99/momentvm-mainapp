module Types
  class TranslationEditorColorType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :hex, String, null: false
  end
end