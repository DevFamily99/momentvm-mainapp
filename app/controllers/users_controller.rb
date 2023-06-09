class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :require_permission, only: [:show, :update, :destroy]
  before_action :require_admin, only: [:index]
  before_action :require_edit_permission, only: :edit

  # GET /users
  # GET /users.json
  def index
    @users = User.by_team(current_user)
  end

  # GET /users/1
  # GET /users/1.json
  def show; end

  # GET /users/new
  def new
    puts 'New'
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    redirect_to users_path, alert: 'App admin cannot be changed' if @user.app_admin? && !current_user.app_admin?
  end

  # POST /users
  # POST /users.json
  def create
    puts 'create'

    @user = User.new(user_params.merge(team_id: current_user.team_id))
    password = @user.generate_password
    @user.password = password
    @user.password_confirmation = password

    selected_locales_params = params['locales']
    selected_locales = []
    selected_locales_params&.each do |country_id, _country_name|
      selected_locales << country_id
    end

    @user.allowed_countries = selected_locales.to_json.to_s

    respond_to do |format|
      if @user.save
        @user.send_password_create
        format.html { redirect_to @user, notice: 'User was successfully created. An Email with instructions has been sent to the user' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
    end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    selected_locales_params = params['locales']
    selected_locales = []
    selected_locales_params&.each do |country_id, _country_name|
      selected_locales << country_id
    end

    @user.allowed_countries = selected_locales.to_json.to_s

    # puts selected_locales

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def require_permission
    @user = User.find(params[:id])

    redirect_to root_path, alert: "Restricted content. You don't have access to this page." if @user.team_id != current_user.team_id && !current_user.is_admin?
  end

  def require_edit_permission
    if params[:id].to_i == current_user.id || current_user.app_admin? || current_user.is_admin?
    else
      redirect_to root_path, alert:  "Restricted content. You don't have access to this page."
    end
  end

  def require_admin
    redirect_to root_path, alert: "Restricted content. You don't have access to this page." if !current_user.is_admin? && !current_user.app_admin?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :team_id)
  end
end
