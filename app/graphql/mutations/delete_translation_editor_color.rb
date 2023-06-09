module Mutations
  class DeleteTranslationEditorColor < GraphQL::Schema::RelayClassicMutation
    argument :name, String, required: true
    field :color, Types::TranslationEditorColorType, null: true
  
    def resolve(name:)
      current_user = context[:current_user]
      color = TranslationEditorColor.where(team_id: current_user.team_id).find_by_name(name)
      color.destroy!
      { color: color }
     end

  end
end
