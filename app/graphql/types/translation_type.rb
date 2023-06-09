module Types
  class TranslationType < BaseObject
    field :id, ID, null: false
    field :body, GraphQL::Types::JSON, null: true
  end
end