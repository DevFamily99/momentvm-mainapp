# frozen_string_literal: true

module Mutations
  # Publish a page as a content asset
  class PublishPage < GraphQL::Schema::RelayClassicMutation
    field :page, Types::ScheduleType, null: false
    argument :page_id, ID, required: true
    argument :publishing_target_id, ID, required: true
    argument :page_context, String, required: true

    def resolve(page_id:, publishing_target_id:, page_context:)
      page = Page.find(page_id)
      page.context = page_context
      page.last_published = DateTime.now
      page.save!
      raise 'Selected page does not have valid country groups' if page.country_groups.empty?
      raise 'Selected page does not have any modules' if page.page_modules.empty?
      raise 'Selected page does not have a set context' if page.context.blank?


      current_user = context[:current_user]
      publishing_target = PublishingTarget.find(publishing_target_id)
      PagePublishWorker.perform_async(current_user.id, publishing_target.id, page.id)

      { page: page }
    end
  end
end
