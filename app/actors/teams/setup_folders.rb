module Teams
  # Setup the root page and image folder for a team
  class SetupFolders < Actor
    input :team, allow_nil: false

    def call
      root_folder = PageFolder.find_or_create_by!(name: team.name, team_id: team.id)

      PageFolder.find_or_create_by!(
        name: 'Archive', team_id: team.id, page_folder_id: root_folder.id
      )
      AssetFolder.find_or_create_by!(name: 'Images', team_id: team.id)
    end

    def rollback
      team.page_folders.destroy_all
      team.asset_folders.destroy_all
    end
  end
end
