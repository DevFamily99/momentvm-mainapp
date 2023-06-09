
# Api Authentication
class Api::PasswordResetsController < Api::ApiController
  skip_before_action :require_token
  before_action :check_attempts
  
  def new    
    user = User.find_by_email params[:email]
    if !user
        return render json: {error: "User with this email not found."}, status: 400
    end
    user.send_password_reset
    return render json: {message: "Password Reset link has been sent to your email."}
  end

  def reset
    user = User.find_by_reset_password_token!(params[:token])
    user.password = params[:password]
    user.password_confirmation = params[:passwordConfirmation]
    if user.save
        return render json: {message: "Password reset successfully"}
    else
        return render json: {error: user.errors.full_messages[0]}, status: 422
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
