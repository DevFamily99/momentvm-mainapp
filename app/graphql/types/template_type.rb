module Types
  class TemplateType < BaseObject
    field :id, ID, null: false
    field :schema, GraphQL::Types::JSON, null: false
    field :ui_schema, GraphQL::Types::JSON, null: false
    field :ui_schema_yaml, String, null: true
    field :name, String, null: false
    field :description, String, null: true
    field :image_url, String, null: true
    field :template_schema, TemplateSchemaType, null: true
    field :body, String, null: true
    field :secondary_body, String, null: true
    field :schemaBody, String, null: true
    field :version_count, Integer, null: false
    field :versions, [Types::VersionType], null: true
    field :tags, [Types::TagType], null: true
    field :tag_ids, [ID], null: true
    field :archived, Boolean, null: false

    def image_url
      object.image.service_url
    rescue StandardError => e
      ''
    end

    def schema
      YAML.load(object.template_schema.body)
    end

    def ui_schema
      YAML.load(object.template_schema.ui_schema || '')
    end

    def ui_schema_yaml
      object.template_schema.ui_schema
    end

    def version_count
      object.versions.count
    end

    delegate :versions, to: :object
  end
end
