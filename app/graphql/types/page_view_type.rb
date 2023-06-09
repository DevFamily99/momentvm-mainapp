module Types
  class PageViewType < BaseObject
    field :id, ID, null: false
    field :page, PageType, null: false
    field :user, UserType, null: false
  end
end
