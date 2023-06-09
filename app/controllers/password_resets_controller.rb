class PasswordResetsController < ApplicationController
  
  skip_before_action :require_login
 

  def new
  end

  def create
    user = User.find_by_email(params[:email])
    user.send_password_reset unless !user 
    redirect_to root_path, notice: "Email sent with password reset instructions"
  end

  def create_password
    @user = User.find_by_reset_password_token!(params[:id])
  end

  def set_password
    @user = User.find_by_reset_password_token!(params[:id])
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    @user.save!
      if @user.save!
        redirect_to ENV["FRONTEND_URL"], :notice => "Password has been reset"
      else
        render :edit
      end
  end


  def edit
    @user = User.find_by_reset_password_token!(params[:id])
  end

  def update
    @user = User.find_by_reset_password_token!(params[:id])
    if @user.reset_password_email_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired" 
    else

      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      @user.save!
      if @user.save!
        redirect_to ENV["DEFAULT_HOST"], :notice => "Password has been created"
      else
        render :edit
      end
    end
  end
end
