require 'translation_service'
module Mutations
  # Languagewire fetch translation assignment and update stored translation
  class FetchTranslationAssignment < GraphQL::Schema::RelayClassicMutation
    field :message, String, null: false
    argument :project_id, ID, required: true

    def resolve(project_id:)
      t = TranslationService.new

      t.fetch_assignment(project_id)
      raise 'Error importing translations' unless t.body

      { message: 'Translations imported' }
    end
  end
end
