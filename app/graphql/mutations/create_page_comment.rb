module Mutations
  # Create a new page commment
  class CreatePageComment < GraphQL::Schema::RelayClassicMutation
    field :page_comment, Types::PageCommentType, null: false

    argument :page_id, ID, required: true
    argument :body, String, required: true

    def resolve(page_id:, body:)
      { page_comment: Pages::NewPageComment.call(page_id: page_id, user_id: context[:current_user].id, body: body).page_comment }
    end
  end
end
