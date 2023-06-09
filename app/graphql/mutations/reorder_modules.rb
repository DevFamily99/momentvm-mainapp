
include PageModulesHelper
module Mutations
  class ReorderModules < GraphQL::Schema::RelayClassicMutation
    field :message, String, null: false
    argument :ids, [String], required: true

    def resolve(input)
      current_user = context[:current_user]
      ranks = generate_random_strings(input[:ids].length)
      input[:ids].each_with_index do |page_module_id, index|
        page_module = PageModule.find(page_module_id)
        page_module.rank = ranks[index]
        page_module.save
      end
      return {message: "Modules reordered."}
    end
  end
end
