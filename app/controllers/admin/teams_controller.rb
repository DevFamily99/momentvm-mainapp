# frozen_string_literal: true

module Admin
  class TeamsController < ::ApplicationController
    require 'translation_service'

    before_action :require_permission
    before_action :setup_team, only: %i[show edit update destroy]

    def index
      @teams = Team.all
      
    end

    def new
      @team = Team.new
    end

    def show; end

    def edit; end

    def create
      @team = Team.new(team_params)
      @team.approved = false

      clientSubject = 'Your registration to MOMENTVM was successful'
      approverSubject = 'New registration for ' + @team.name
      approver = ENV['APPROVER_MAIL']

      respond_to do |format|
        if @team.save
          ApplicationMailer.send_register_team_mail(@team.owner_email)
            .deliver_later
          ApplicationMailer.send_register_team_mail_to_approver(approver, @team)
            .deliver_later

          format.html do
            redirect_to :root,
                        notice:
                          'Team was successfully created. Please check your email for instructions.'
          end
          format.json { render :show, status: :created, location: @team }
        else
          format.html { render :new }
          format.json do
            render json: @team.errors, status: :unprocessable_entity
          end
        end
      end
    end

    def update
      respond_to do |format|
        if @team.update(team_params)
          format.html do
            redirect_to [:admin, @team],
                        notice: 'Team was successfully updated.'
          end
          format.json { json_response(@team, :updated) }
        else
          format.html { render :edit }
          format.json do
            render json: { errors: @team.errors, status: :unprocessable_entity }
          end
        end
      end
    end

    def destroy
      puts "destroy"
      @team.destroy
      respond_to do |format|
        format.html do
          redirect_to admin_teams_url,
                      notice: 'Team was successfully destroyed.'
        end
        format.json { head :no_content }
      end
    end

 
    def set_team
      if current_user.app_admin
        current_user.team = Team.friendly.find params[:id]
        current_user.save!
      end
      redirect_back fallback_location: root_path
    end

    private

    def setup_team
      @team = Team.friendly.find(params[:id])
    end

    def team_params
      params.require(:team).permit(
        :owner_firstname,
        :owner_lastname,
        :owner_email,
        :name,
        :preview_url,
        :webdav_name,
        :webdav_password,
        :publishing_url_stg,
        :publishing_url_dev,
        :publishing_url_sandbox,
        :client_id,
        :client_secret,
        :preview_wrapper_url,
        :plan_id,
        :selector
      )
    end

    def require_permission
      if current_user&.app_admin

      else
        redirect_to root_path,
                    alert:
                      "Restricted content. You don't have access to this page."
      end
    end


   
    
  end
end
