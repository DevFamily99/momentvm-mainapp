require 'translation_service'
require 'application_mailer'

module Mutations
  class UpdateTeam < GraphQL::Schema::RelayClassicMutation
    field :team, Types::TeamType, null: false
    argument :id, ID, required: true
    argument :approveTeam, Boolean, required: false
    argument :name, String, required: false
    argument :initials, String, required: false
    argument :owner_email, String, required: false
    argument :owner_firstname, String, required: false
    argument :owner_lastname, String, required: false
    argument :preview_wrapper_url, String, required: false
    argument :selector, String, required: false
    argument :preview_render_additive, String, required: false
    argument :client_id, String, required: false
    argument :client_secret, String, required: false

    def resolve(input)
      team = Team.find(input[:id])

      if input[:approveTeam]
        team = Teams::ApproveTeam.call(team: team).team
        return { team: team }
      end

      team.update(input)
      { team: team }
    end
  end
end
