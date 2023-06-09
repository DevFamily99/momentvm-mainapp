module Types
  class AssetFolderType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :path, String, null: false
    field :asset_folders, [AssetFolderType], null: true
    field :assets, Connections::AssetConnection, null: false do
      argument :order, String, required: true
      argument :direction, String, required: true
    end
    field :team_id, Int, null: true
    field :root, Boolean, null: true
    field :breadcrumbs, [GraphQL::Types::JSON], null: true

    def assets(order:, direction:)
      object.assets.order("#{order} #{direction}")
    end

    def root
      object.root?
    end

    def breadcrumbs
      Folders::GenerateBreadcrumbs.call(folder: object).breadcrumbs
    end
  end
end
