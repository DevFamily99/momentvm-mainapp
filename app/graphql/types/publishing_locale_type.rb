# frozen_string_literal: true

module Types
  class PublishingLocaleType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :locale, String, null: false
  end
end
