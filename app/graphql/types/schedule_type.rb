# frozen_string_literal: true

module Types
  class ScheduleType < BaseObject
    field :id, ID, null: false
    field :page_id, ID, null: false
    field :start_at, GraphQL::Types::ISO8601DateTime, null: true
    field :end_at, GraphQL::Types::ISO8601DateTime, null: true
    field :published, Boolean, null: false
    field :country_groups, [CountryGroupType], null: true
    field :customer_groups, [CustomerGroupType], null: true
    field :page_modules, [PageModuleType], null: true
    field :campaign_id, String, null: true
    field :image_url, String, null: true
    field :publishing_manifests, [PublishingManifestType], null: true

    def publishing_manifests
      object.publishing_manifests.order(created_at: :desc).limit(10)
    end

    def image_url
      object.thumbnail.service_url
    rescue StandardError
      nil
      # 'https://via.placeholder.com/360x320?text=Preview+not+available'
    end
  end
end
