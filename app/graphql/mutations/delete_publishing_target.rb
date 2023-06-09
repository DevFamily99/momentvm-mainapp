module Mutations
  class DeletePublishingTarget < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true

    field :publishingTarget, Types::PublishingTargetType, null: true
  
    def resolve(id:)
      publishingTarget = PublishingTarget.find(id)
      publishingTarget.destroy!
      { publishingTarget: publishingTarget }
     end

  end
end
