module Mutations
  # Delete a tag
  class DeleteTag < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true

    field :tag, Types::TagType, null: true

    def resolve(id:)
      tag = Tag.find(id)
      tag.destroy!
      { tag: tag }
    end
  end
end
