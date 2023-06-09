module Types
  class RoleWhitelistType < BaseObject
    field :id, ID, null: false
    field :role_id, ID, null: false
    field :page_module_id, ID, null: false
  end
end