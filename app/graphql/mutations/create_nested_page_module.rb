module Mutations
  # Create a page module that is a child of an existing page module
  class CreateNestedPageModule < GraphQL::Schema::RelayClassicMutation
    field :page_module, Types::PageModuleType, null: false
    argument :field_id, String, required: true
    argument :page_module_id, ID, required: true
    argument :template_id, ID, required: true
    argument :page_module_body, GraphQL::Types::JSON, required: true

    def resolve(input)
      current_user = context[:current_user]
      parent_module = PageModule.find(input[:page_module_id])
      nested_module = PageModule.create!(
        team: current_user.team,
        rank: 'nested',
        body: input[:page_module_body].as_json.to_yaml,
        page_module: parent_module,
        template_id: input[:template_id]
      )
      PageModules::SaveNestedModuleId.call(parent_module: parent_module, field_id: input[:field_id], nested_module: nested_module)
      { page_module: nested_module }
    end
  end
end
