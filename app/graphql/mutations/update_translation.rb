require 'translation_service'

module Mutations
  class UpdateTranslation < GraphQL::Schema::RelayClassicMutation
    field :message, String, null: false
    argument :id, ID, required: true
    argument :translation_body, GraphQL::Types::JSON, required: true


    def resolve(input)
        translation_service = TranslationService.new
        translation_service.update_translation(
          input[:id],
          input[:translation_body],
          context[:current_user]
          ) do |error|
            if error.nil?
              return {message: JSON.parse(translation_service.body)}
            else
              raise "Translation Update failed."
            end
        end
    end

  end
end
