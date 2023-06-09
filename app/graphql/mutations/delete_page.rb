module Mutations
  class DeletePage < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true
    field :page, Types::PageType, null: true

    def resolve(id:)
      current_user = context[:current_user]
      raise 'Permission denied' unless current_user.has_skill?('can_create_pages')

      page = Page.find(id)
      page.destroy!
      { page: page }
    end
  end
end
