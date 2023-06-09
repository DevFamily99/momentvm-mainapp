module Mutations
  class CreateTemplate < GraphQL::Schema::RelayClassicMutation
    field :template, Types::TemplateType, null: false

    argument :name, String, required: true
    argument :description, String, required: false
    argument :schema_body, String, required: false
    argument :body, String, required: false
    argument :secondary_body, String, required: false
    argument :ui_schema, String, required: false
    argument :tag_ids, [ID], required: true

    def resolve(name:,
                description:,
                schema_body:,
                body:,
                secondary_body:,
                ui_schema:,
                tag_ids:)
      current_user = context[:current_user]

      raise 'You need to set a template name' unless name != ""

      template = Template.create!(
        name: name,
        description: description,
        body: body,
        secondary_body: secondary_body,
        team: current_user.team,
        tag_ids: tag_ids
      )

      TemplateSchema.create!(
        body: schema_body,
        ui_schema: ui_schema,
        template_id: template.id,
        team: current_user.team
      )
      {
        template: template
      }
    end
  end
end
