require 'translation_service'

module Mutations
  class DeleteTranslation < GraphQL::Schema::RelayClassicMutation
    field :message, String, null: false
    argument :id, ID, required: true
    argument :page_id, ID, required: true
    argument :attribute_translation, Boolean, required: false
    argument :attribute_field, String,  required: false



    def resolve(input)
        if input[:attribute_translation]
            delete_attribute_translation(input)
        end
    end
    
    private

    def delete_attribute_translation(input)
        page = Page.find(input[:page_id])
        page[input[:attribute_field]] = nil
        page.save
        ts = TranslationService.new
        ts.delete_translation(input[:id], context[:current_user]) do |error|
            if error.nil?
                return { message: "ok",  }
            else
                raise "Error deleting translation."
            end
        end
        
    end

  end
end
