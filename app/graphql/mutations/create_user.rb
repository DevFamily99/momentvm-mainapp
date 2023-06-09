class Mutations::CreateUser < GraphQL::Schema::RelayClassicMutation
  argument :email, String, required: true
 
  field :user, Types::UserType, null: true
  field :errors, [String], null: false

  def resolve(params)
    user = User.new
    user.email = params[:email]
    rand = user.generate_password
    user.password = rand
    user.password_confirmation = rand
    user.team_id = context[:current_user].team_id
    
    if user.save
      user.send_password_create
      {
        user: user
      }
    else
      raise user.errors.full_messages.join
    end
  end
end
