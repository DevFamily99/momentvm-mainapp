module Mutations
  # Update a page module on a page
  class UpdatePageModule < GraphQL::Schema::RelayClassicMutation
    field :page_module, Types::PageModuleType, null: false
    argument :id, ID, required: true
    argument :page_module_body, GraphQL::Types::JSON, required: false

    def resolve(input)
      current_user = context[:current_user]
      page_module = PageModule.find(input[:id])
      # Workaround to prevent YAML to contain Parameters 
      # and HashWithIndifferentAccess which makes accessing the module crash
      plain_hash = JSON.parse(input[:page_module_body].to_json)
      page_module.update!(body: plain_hash.to_yaml)
      Templates::UnarchiveTemplate.call(template: page_module.template) if page_module.template.archived
      PageActivity.create(
        user: current_user,
        note: 'Page was edited',
        activity_type: :edit,
        team_id: current_user.team_id,
        page: page_module.pages.first
      )
      { page_module: page_module }
    end
  end
end
