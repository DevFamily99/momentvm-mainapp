require 'concerns/captcha_concern'
# require 'errors'

# Controls team actions
class TeamsController < ApplicationController
  rescue_from Errors::NetworkError do |e|
    respond_to do |format|
      format.any do
        render status: 500, json: e
      end
    end
  end

  include CaptchaConcern
  skip_before_action :verify_authenticity_token

  before_action :set_team, only: %i[show edit update destroy use_demo_data]
  # before_action :require_admin_permission, only: %i[edit update]
  # before_action :captcha_verify,
  #               only: %i[create_api], if: -> { Rails.env.production? }
  require 'bcrypt'

  def new
    @team = Team.new
  end

  def signup
    @team = Team.new
  end

  def settings; end

  def retrieve_current_team
    render json: current_user.team
  end

  def check_team_setup
    salesforce_credentials = true
    if current_user.team.client_id.blank? ||
       current_user.team.client_secret.blank?
      salesforce_credentials = false
    end
    preview_settings = true
    if current_user.team.preview_wrapper_url.blank? ||
       current_user.team.selector.blank?
      preview_settings = false
    end

    render json: {
      show_setup_assistant: current_user.team.show_setup_assistant,
      preview_settings: preview_settings,
      salesforce_credentials: salesforce_credentials
    }
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = Team.new(team_params)
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
        format.html { render :signup }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  def use_demo_data
    @team.show_setup_assistant = true
    if @team.save
      render json: { message: 'Ok' }
    else
      @team.errors
    end
  end

  def team_sites
    # set the limit from the teams plan when we set those up
    render json: {
      sites: current_user.team.sites,
      limit: current_user.team.plan.country_limit
    }
  end

  # Fetches [Site] from salesforce
  def salesforce_sites
    unless current_user.team.publishing_targets.find(
      params['publishing_target']
    )
      return render json: { error: 'No publishing targets found.' }, status: 400
    end

    team = current_user.team
    sites = team.salesforce_sites(params['publishing_target'])
    if sites
      render json: { sites: sites }
    else
      render json: { error: 'Error fetching salesforce sites.' }, status: 500
    end
  end

  def import_sites
    team = current_user.team
    sites = team_params[:sites].to_h
    publishing_target_id = params['publishing_target_id']
    sites = sites.map { |key, val| key if val }.compact
    salesforce_sites = team.salesforce_sites(publishing_target_id)
    salesforce_sites.each do |sf_site|
      next unless sites.include?(sf_site['id']) &&
                  !Site.find_by(team_id: team.id, salesforce_id: sf_site['id'])

      # create  coutry
      site =
        Site.create(
          team_id: team.id,
          salesforce_id: sf_site['id'],
          name: sf_site['display_name']['default']
        )
      # Loop and get all locales of a site
      site.salesforce_locales(publishing_target_id).each do |loc|
        Locale.create!(
          site_id: site.id,
          code: loc['id'],
          name: loc['name'],
          display_name: loc['display_name'],
          display_country: loc['display_country'],
          display_language: loc['display_language'],
          default: loc['default']
        )
      end
    end

    render json: { message: 'Sites imported.' }
  end

  def clear_sites
    if current_user.team.sites.destroy_all
      render json: { message: 'All countries deleted.' }
    else
      render json: { message: 'Error deleting countries.' }, status: 500
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    if @team.update(team_params)
      render json: { team: @team, status: :ok }
    else
      render json: {
        team: @team, errors: @team.errors, status: :unprocessable_entity
      }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team = current_user.team
  end

  def require_admin_permission
    if current_user.team_id != params[:id].to_i || !current_user.app_admin
      redirect_to root_path,
                  alert:
                    "Restricted content. You don't have access to this page."
    end
  end

  def require_permission
    if current_user&.app_admin

    else
      redirect_to root_path,
                  alert:
                    "Restricted content. You don't have access to this page."
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
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
      :selector,
      :preview_render_additive,
      :publishing_target_id,
      sites: {}
    )
  end
end
