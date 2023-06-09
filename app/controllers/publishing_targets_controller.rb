class PublishingTargetsController < ApplicationController
  before_action :set_publishing_target, only: [:show, :edit, :update, :destroy]

  # GET /publishing_targets
  # GET /publishing_targets.json
  def index
    @publishing_targets = PublishingTarget.where(team: current_user.team)
  end

  # GET /publishing_targets/1
  # GET /publishing_targets/1.json
  def show
  end

  # GET /publishing_targets/new
  def new
    @publishing_target = PublishingTarget.new
   @publishing_target.team = current_user.team
  end

  # GET /publishing_targets/1/edit
  def edit
  end

  # POST /publishing_targets
  # POST /publishing_targets.json
  def create
    @publishing_target = PublishingTarget.new(publishing_target_params)
    @publishing_target.team = current_user.team
    respond_to do |format|
      if @publishing_target.save
        format.html { redirect_to @publishing_target, notice: 'Publishing target was successfully created.' }
        format.json { render :show, status: :created, location: @publishing_target }
      else
        format.html { render :new }
        format.json { render json: @publishing_target.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /publishing_targets/1
  # PATCH/PUT /publishing_targets/1.json
  def update
    respond_to do |format|
      if @publishing_target.update(publishing_target_params)
        format.html { redirect_to @publishing_target, notice: 'Publishing target was successfully updated.' }
        format.json { render :show, status: :ok, location: @publishing_target }
      else
        format.html { render :edit }
        format.json { render json: @publishing_target.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /publishing_targets/1
  # DELETE /publishing_targets/1.json
  def destroy
    @publishing_target.destroy
    respond_to do |format|
      format.html { redirect_to publishing_targets_url, notice: 'Publishing target was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_publishing_target
      @publishing_target = PublishingTarget.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def publishing_target_params
      params.require(:publishing_target).permit(:name, :publishing_url, :webdav_username, :webdav_password, :webdav_path, :preview_url, :team_id, :default_library, :catalog)
    end
end
