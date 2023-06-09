module Mutations
  # Update a custom setting
  class UpdateSetting < GraphQL::Schema::RelayClassicMutation
    argument :name, String, required: true
    argument :body, String, required: true

    field :setting, Types::SettingType, null: false

    def resolve(name:, body:)
      current_user = context[:current_user]
      setting = Setting.where(team_id: current_user.team_id).find_by(name: name)
      setting.update!(body: body)
      {
        setting: setting
      }
    end
  end
end
