module Types
  class PublishingEventType < BaseObject
    field :display_name, String, null: false
    field :category, String, null: false
    field :message, GraphQL::Types::JSON, null: false
    field :status, String, null: true

  end
end
