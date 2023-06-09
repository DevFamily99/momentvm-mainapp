module Mutations
  class DeleteTemplate < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true
    field :template, Types::TemplateType, null: true

    def resolve(id:)
      template = Template.find(id)
      template.destroy!
      { template: template }
    end
  end
end
