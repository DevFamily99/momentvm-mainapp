module Mutations
  # Mutation to create a new tag
  class CreateTag < GraphQL::Schema::RelayClassicMutation
    argument :name, String, required: true

    field :tag, Types::TagType, null: true

    def resolve(name:)
      tag = Tag.new
      tag.name = name
      tag.team = context[:current_user].team
      tag.save!
      { tag: tag }
    end
  end
end
