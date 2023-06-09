
# Api Authentication
class Api::SessionsController < Api::ApiController
  skip_before_action :require_token
  before_action :check_attempts
  
  def login
    user = User.find_by_email params[:email]
    if !user
      return render json: {error: "User with this email not found."}, status: 400
    end
    # this is a sorcery method
    if user.valid_password? params[:password]
        # genereate a jwt
        return render json: {token: user.generate_api_token}
    else
        return render json: {error: "Password or email is incorrect."}, status: 400
    end

  end

  private
  def check_attempts
    count = Rails.cache.read(params[:email])
    if count && count.to_i > 5
        return render json: {error: "You're doing that too much, try again in minute."}, status: 400
    end
    Rails.cache.write(params[:email], (count.to_i) + 1, ex: 60)
  end

end
