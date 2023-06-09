module Mutations
  class DeleteAssetFolder < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true

    field :message, String, null: true

    def resolve(id:)
      asset_folder = AssetFolder.find(id)
      asset_folder.destroy
      { message: 'Success' }
    end
  end
end
