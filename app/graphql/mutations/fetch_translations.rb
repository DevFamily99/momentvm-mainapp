require 'translation_service'
module Mutations
  class FetchTranslations < GraphQL::Schema::RelayClassicMutation
    field :message, String, null: false
    argument :job_ids, [ID], required: true

    def resolve(job_ids:)
      t = TranslationService.new
      responses = job_ids.map { |job_id| t.fetch_translations(job_id) }
      return { message: 'Translations imported' }
    end
  end
end
