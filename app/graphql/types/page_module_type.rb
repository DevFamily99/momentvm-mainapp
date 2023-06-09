module Types
  # Page module graphql type
  class PageModuleType < BaseObject
    field :id, ID, null: false
    field :body, GraphQL::Types::JSON, null: false
    field :template, TemplateType, null: false
    field :page, PageType, null: true
    field :parent, PageModuleType, null: true
    field :permission, Boolean, null: true
    field :rank, String, null: true

    def body
      YAML.load(object.body)
    end

    def page
      object.pages.first
    end

    def permission
      current_user = context[:current_user]
      return true if current_user.skills.include?(:can_edit_all_modules_by_default)
      return true if PageModuleRoleWhitelist.find_by(page_module_id: object.id, role: current_user.roles.ids)

      false
    end
  end
end
