module Mutations
  class ArchiveTemplate < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true
    field :template, Types::TemplateType, null: true

    def resolve(id:)
      template = Template.find(id)
    
      template.archived = true;
      template.save!
      puts template.inspect
      { template: template }
    end
  end
end
