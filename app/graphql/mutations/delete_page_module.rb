module Mutations
  # Delete a page module
  class DeletePageModule < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true

    field :message, String, null: true

    def resolve(id:)
      page_module = PageModule.find(id)
      PageModules::RemoveNestedModuleId.call(parent_module: page_module.page_module, nested_module: page_module) if page_module.page_module
      page_module.destroy!
      { message: 'Success' }
    end
  end
end
