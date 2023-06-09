module Types
  # PaperTrail Version object
  class VersionType < BaseObject
    field :id, ID, null: false
    field :item_type, String, null: false
    field :whodunnit, String, null: true
    field :body, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def body
      YAML.load(object.object)['body']
    end
  end
end
