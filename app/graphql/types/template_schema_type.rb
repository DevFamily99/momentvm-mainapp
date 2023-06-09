module Types
  class TemplateSchemaType < BaseObject
    field :id, ID, null: false
    field :body, String, null: true
    field :json_body, String, null: true

    def json_body
      YAML.load(object.body).to_json
    end

  end
end
