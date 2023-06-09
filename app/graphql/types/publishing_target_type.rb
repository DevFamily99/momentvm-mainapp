module Types
  class PublishingTargetType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :name, String, null: false
    field :publishing_url, String, null: true
    field :catalog, String, null: true
    field :default_library, String, null: true
    field :webdav_username, String, null: true
    field :webdav_password, String, null: true
    field :webdav_path, String, null: true
    field :preview_url, String, null: true
  end
end
