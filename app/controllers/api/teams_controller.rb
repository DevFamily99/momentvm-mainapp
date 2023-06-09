module Api
  class TeamsController < ApiController
    skip_before_action :require_token, only: :create

    # Creates a team though the signup process
    def create
      @team = Team.new(team_params)
      @team.plan = Plan.all.find_by(name: 'Free Plan')
      @team.initials = ''
      approver = ENV['APPROVER_MAIL']
      if @team.save
        ApplicationMailer.send_register_team_mail(@team.owner_email).deliver_later
        ApplicationMailer.send_register_team_mail_to_approver(approver, @team)
                         .deliver_later
        render json: { team: @team }, status: :created
      else
        puts @team.errors.full_messages
        render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
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
        render json: { message: 'Error deleting countries.' }, status: :internal_server_error
      end
    end

    private

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
end
