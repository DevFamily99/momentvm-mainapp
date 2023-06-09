module Types
  class GlobalSearchResultType < BaseObject
    field :pages, [PageType], null: true
    field :assets, [AssetType], null: true
  end
end