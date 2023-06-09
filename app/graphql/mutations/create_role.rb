class Mutations::CreateRole < GraphQL::Schema::RelayClassicMutation
  argument :name, String, required: true
  argument :body,  GraphQL::Types::JSON, required: true
  argument :users,  [GraphQL::Types::JSON], required: false
 
  field :role, Types::RoleType, null: true
  field :errors, [String], null: false

  def resolve(params)
    role = Role.new
    role.name = params[:name]
    role.team_id = context[:current_user].team_id
    # Deprecated
    # role.body = params[:body].permit!.to_h
    role.body = ""

    body = params[:body].permit!.to_h
    puts body
    role.can_create_pages = body["can_create_pages"] || false
    role.can_edit_pages = body["can_edit_pages"] || false
    role.can_approve_pages = body["can_approve_pages"] || false
    role.can_see_advanced_menu = body["can_see_advanced_menu"] || false
    role.can_edit_templates = body["can_edit_templates"] || false
    role.can_see_language_preview = body["can_see_language_preview"] || false
    role.can_see_country_preview = body["can_see_country_preview"] || false
    role.can_unpublish_pages = body["can_unpublish_pages"] || false
    role.can_publish_pages = body["can_publish_pages"] || false
    role.can_edit_settings = body["can_edit_settings"] || false
    role.can_see_settings = body["can_see_settings"] || false
    role.can_edit_all_modules_by_default = body["can_edit_all_modules_by_default"] || false
    role.can_edit_module_permissions = body["can_edit_module_permissions"] || false
    role.can_copy_modules = body["can_copy_modules"] || false
    role.can_duplicate_page = body["can_duplicate_page"] || false

    if role.save
      params[:users].each do |user|
        role.users << User.find(user[:id])
      end
      {
        role: role
      }
    else
      raise role.errors.full_messages.join
    end
  end
end
