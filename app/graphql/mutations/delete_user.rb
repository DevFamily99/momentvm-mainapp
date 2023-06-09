module Mutations
  class DeleteUser < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true

    field :user, Types::UserType, null: true
  
    def resolve(id:)
      user = User.find(id)
      user.destroy!
      { user: user }
     end

  end
end
