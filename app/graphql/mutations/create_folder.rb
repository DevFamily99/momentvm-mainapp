module Mutations
  # Create a new asset or page folder
  class CreateFolder < GraphQL::Schema::RelayClassicMutation
    field :message, String, null: false

    argument :folder_id, ID, required: true
    argument :name, String, required: true
    argument :folder_type, String, required: true

    def resolve(name:, folder_id:, folder_type:)
      current_user = context[:current_user]
      case folder_type
      when 'asset'
        folder = AssetFolder.create!(name: name, asset_folder_id: folder_id, team_id: current_user.team_id)
      when 'page'
        folder = PageFolder.create!(name: name, page_folder_id: folder_id, team_id: current_user.team_id)
      end
      folder.generate_path
      folder.save!
      {
        message: 'Folder created.'
      }
    end
  end
end
