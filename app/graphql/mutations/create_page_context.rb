# frozen_string_literal: true

module Mutations
  class CreatePageContext < GraphQL::Schema::RelayClassicMutation
    field :page_context, Types::PageContextType, null: false

    argument :name, String, required: true
    argument :context_type, String, required: true
    argument :slot, String, required: true
    argument :rendering_template, String, required: false
    argument :selector, String, required: false
    argument :preview_wrapper_url, String, required: false

    def resolve(name:, context_type:, slot:, rendering_template:,  selector:, preview_wrapper_url: )
      current_user = self.context[:current_user]
      page_context = PageContext.new(
                      name: name, 
                      context: context_type, 
                      slot: slot, 
                      rendering_template: rendering_template,
                      selector: selector, 
                      preview_wrapper_url: preview_wrapper_url,
                      team: current_user.team
                    )
      if page_context.save
        {
          page_context: page_context
        }
      else
        p page_context.errors[:name]
        errors_json = {}
        page_context.errors.keys.each do |key|
          errors_json[key] = page_context.errors[key]
        end
        raise GraphQL::ExecutionError, errors_json.to_json
      end
     end
  end
end
