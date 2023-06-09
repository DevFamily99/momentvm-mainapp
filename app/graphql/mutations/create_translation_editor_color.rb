module Mutations
  class CreateTranslationEditorColor < GraphQL::Schema::RelayClassicMutation
    field :color, Types::TranslationEditorColorType, null:false

    argument :name, String, required: true
    argument :hex, String, required: true
  
    def resolve(name:, hex: )
      current_user = self.context[:current_user]

      color = TranslationEditorColor.new(team_id: current_user.team_id, name: name, hex: hex)
      
      if color.save
        return { color: color }
      else
        raise color.errors.full_messages[0]  
      end
     end

  end


end
