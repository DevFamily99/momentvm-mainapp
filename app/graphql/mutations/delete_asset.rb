module Mutations
    class DeleteAsset < GraphQL::Schema::RelayClassicMutation
      argument :id, ID, required: true
  
      field :message, String, null: true
    
      def resolve(id:)
        asset = Asset.find(id)
        asset.destroy!
        { message: "Success" }
       end
  
    end
  end
  