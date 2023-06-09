module Mutations
  class DeleteRole < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true

    field :role, Types::RoleType, null: true
  
    def resolve(id:)
      role = Role.find(id)
      role.destroy!
      { role: role }
     end

  end
end
