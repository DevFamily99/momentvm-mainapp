module Mutations
    class RestoreFromArchive < GraphQL::Schema::RelayClassicMutation
      field :message, String, null: false
      argument :id, ID, required: true
      argument :type, String, required: true
      
      def resolve(id:, type:)
        page_root_folder = PageFolder.where(team: context[:current_user].team_id, page_folder_id: nil).first
        if type == "folder"
          folder = PageFolder.find(id)
          folder.page_folder = page_root_folder
          folder.save!
        elsif type == "page"
          page = Page.find(id)
          page.deleted_from_archive = DateTime.now
          page.page_folder = page_root_folder
          page.save!
        end
        {message: "#{type.capitalize} restored successfully."}
      end
    end
  end
  