require 'translation_service'

module Teams
  # Creates a new on the translation microservice
  class CreateTeamOnTranslationService < Actor
    input :team, allow_nil: false

    def call
      ts = TranslationService.new
      fail!(error: 'Failed to create a team on the translation service') unless ts.create_team(team)
    end
  end
end
