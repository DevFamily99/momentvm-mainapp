module Types
  class PgSearchDocumentType < BaseObject
    field :searchable_id, ID, null: false
    field :content, String, null: false
    field :searchable_type, String, null: false
  end
end
