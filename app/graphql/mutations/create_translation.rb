require 'translation_service'

module Mutations
  class CreateTranslation < GraphQL::Schema::RelayClassicMutation
    field :translation, Types::TranslationType, null: false
    argument :page_id, ID, required: false
    argument :attribute_translation, Boolean, required: false
    argument :attribute_field, String,  required: false
    argument :translation_body, GraphQL::Types::JSON, required: true


    def resolve(input)
        if input[:attribute_translation]
           return new_attribute_translation(input, context)
        end
        ts = TranslationService.new
        ts.new_translation(input[:translation_body], context[:current_user]) do |translation_id, error|
            if error.nil?
                return {translation: {id: translation_id}}
            else
                raise "Translation service error."
            end
        end
    end

    private

    def new_attribute_translation(input, context)
        page = Page.find(input[:page_id])
        ts = TranslationService.new
        ts.new_translation(input[:translation_body], context[:current_user]) do |translation_id, error|
            if error.nil?
                page[input[:attribute_field]] = translation_id
                page.save!
                return {translation: {id: translation_id}}
            else
                p 'error translation_service.new_translation'
            end
        end
    end
  end
end
