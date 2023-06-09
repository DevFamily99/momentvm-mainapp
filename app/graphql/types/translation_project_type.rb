module Types
  class TranslationProjectType < BaseObject
    field :id, ID, null: false
    field :submission_id, ID, null: true
    field :title, String, null: false
    field :due_date, String, null: false
    field :created_at, String, null: false
  end
end
