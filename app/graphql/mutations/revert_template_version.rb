module Mutations
  class RevertTemplateVersion < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true
    argument :version_id, ID, required: true

    field :template, Types::TemplateType, null: false

    def resolve(id:, version_id:)
      PaperTrail.request.whodunnit = context[:current_user].email

      template = Template.find(id)
      template = template.versions.find(version_id).reify
      template.save!
      { template: template }
    end
  end
end
