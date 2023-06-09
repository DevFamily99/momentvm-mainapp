require 'translation_service'
require 'application_mailer'

module Mutations
  # Updates a template body and its schema
  class UpdateTemplate < GraphQL::Schema::RelayClassicMutation
    field :template, Types::TemplateType, null: false
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :description, String, required: false
    argument :body, String, required: false
    argument :secondary_body, String, required: false
    argument :schema_body, String, required: false
    argument :ui_schema, String, required: false
    argument :tag_ids, [ID], required: true

    # argument :image, Upload, required: false

    def resolve(input)
      PaperTrail.request.whodunnit = context[:current_user].email

      template = Template.find(input[:id])

      template = Template.new if template.nil?
      raise 'You need to select at least one tag' unless input[:tag_ids].any?
      raise 'You need to set a template name' unless input[:name] != ""

      template.name = input[:name] if input[:name]
      template.description = input[:description] if input[:description]
      template.body = input[:body] if input[:body]
      template.secondary_body = input[:secondary_body] if input[:secondary_body]
      template.tag_ids = input[:tag_ids]

      template_schema = TemplateSchema.find(template.template_schema.id)
      template_schema.body = input[:schema_body] if input[:schema_body]
      template_schema.ui_schema = input[:ui_schema] if input[:ui_schema]

      template.save!
      template_schema.save!
      { template: template }
    end
  end
end
