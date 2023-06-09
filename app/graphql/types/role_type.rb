module Types
  class RoleType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :body, GraphQL::Types::JSON, null: false

    # for real attributes of skills
    field :can_create_pages, Boolean, null: false
    field :can_edit_pages, Boolean, null: false
    field :can_approve_pages, Boolean, null: false
    field :can_see_advanced_menu, Boolean, null: false
    field :can_edit_templates, Boolean, null: false
    field :can_see_language_preview, Boolean, null: false
    field :can_see_country_preview, Boolean, null: false
    field :can_unpublish_pages, Boolean, null: false
    field :can_publish_pages, Boolean, null: false
    field :can_edit_settings, Boolean, null: false
    field :can_see_settings, Boolean, null: false
    field :can_edit_all_modules_by_default, Boolean, null: false
    field :can_edit_module_permissions, Boolean, null: false
    field :can_copy_modules, Boolean, null: false
    field :can_duplicate_page, Boolean, null: false

    field :users, [UserType], null: true

  end
end