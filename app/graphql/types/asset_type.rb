module Types
  class AssetType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :thumbnail, String, null: true
    field :variants, GraphQL::Types::JSON, null: false
    field :asset_folder, AssetFolderType, null: false
    def thumbnail
      object.thumbnail
    end

    def variants
      current_user = context[:current_user]
      object.variants current_user.team.image_settings
    end
  end
end
