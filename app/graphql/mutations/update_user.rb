class Mutations::UpdateUser < GraphQL::Schema::RelayClassicMutation
  argument :id, ID, required: true
  argument :email, String, required: true
  argument :password, String, required: false
  argument :password_confirmation, String, required: false
 
  field :user, Types::UserType, null: true
  field :errors, [String], null: false

  def resolve(params)
    user = User.find(params[:id])
    user.email = params[:email]
    if params[:password]
        user.password = params[:password]
        user.password_confirmation= params[:password_confirmation]
    end
    if user.save
      {
        user: user
      }
    else
        errors_json = {}
        user.errors.keys.each do |key|
            errors_json[key] = user.errors[key]
        end
        raise GraphQL::ExecutionError, errors_json.to_json
    end
  end
end
