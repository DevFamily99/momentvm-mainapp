require 'translation_service'

module Mutations
  # Allows the app admin to change their team
  class SetTeam < GraphQL::Schema::RelayClassicMutation
    field :team, Types::TeamType, null: false
    field :token, String, null: false
    argument :id, String, required: true

    def resolve(input)
      current_user = context[:current_user]
      current_user.team = Team.friendly.find(input[:id])
      raise 'Setting team fails.' unless current_user.save!

      { team: current_user.team, token: current_user.generate_api_token }
    end
  end
end
