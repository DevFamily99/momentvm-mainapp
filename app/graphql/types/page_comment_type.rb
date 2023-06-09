# frozen_string_literal: true

module Types
  class PageCommentType < BaseObject
    field :id, ID, null: false
    field :body, String, null: false
    field :page, PageType, null: false
    field :user, UserType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
