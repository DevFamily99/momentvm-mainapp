# frozen_string_literal: true

module Types
  class PageContextType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :context_type, String, null: false
    field :slot, String, null: false
    field :selector, String, null:true
    field :preview_wrapper_url, String, null: true
    field :rendering_template, String, null: true
  end
end
