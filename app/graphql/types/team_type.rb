module Types
  class TeamType < BaseObject
    description 'Team'
    field :id, ID, null: true
    field :name, String, null: true
    field :owner_email, String, null: true
    field :owner_firstname, String, null: true
    field :owner_lastname, String, null: true
    field :preview_wrapper_url, String, null: true
    field :initials, String, null: true
    field :selector, String, null: true
    field :preview_render_additive, String, null: true
    field :client_id, String, null: true
    field :client_secret, String, null: true
    field :approved, Boolean, null: false
    field :slug, String, null: false
    field :plan, Types::PlanType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :users, [UserType], null: false
    field :roles, [RoleType], null: false
    field :sites, [SiteType], null: false
    field :salesforce_sites, [GraphQL::Types::JSON], null: false do
      argument :publishing_target_id, ID, required: true
    end

    def salesforce_sites(publishing_target_id: nil)
      object.salesforce_sites(publishing_target_id)
    end
  end
end
