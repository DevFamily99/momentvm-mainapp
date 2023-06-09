module Mutations
  class UpdateRoleWhitelist < GraphQL::Schema::RelayClassicMutation
    field :role_whitelist, [Types::RoleWhitelistType], null: false
    argument :page_module_id, ID, required: true
    argument :role_id, ID, required: true

    def resolve(input)
      current_user = context[:current_user]
      raise "You don't have permissions to change this"  unless current_user.has_skill?(:can_edit_module_permissions)

      page_module = PageModule.find(input[:page_module_id])
      role = Role.find(input[:role_id])

      whitelist_item = PageModuleRoleWhitelist.find_by(page_module: page_module, role: role)
      if whitelist_item
        whitelist_item.destroy
      else
        PageModuleRoleWhitelist.create(page_module: page_module, role: role, user: current_user)
      end
      return { role_whitelist: PageModuleRoleWhitelist.where(page_module: page_module)}
    end
  
  end
end
