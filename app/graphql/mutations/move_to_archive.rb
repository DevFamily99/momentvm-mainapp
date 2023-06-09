module Mutations
  class MoveToArchive < GraphQL::Schema::RelayClassicMutation
    field :message, String, null: false
    argument :id, ID, required: true
    argument :type, String, required: true
    
    def resolve(id:, type:)
      page_archive_folder = PageFolder.where(name: 'Archive', team: context[:current_user].team_id).first
      if type == "folder"
        raise "You can't archive the archive folder" if id.to_s == page_archive_folder.id.to_s
        folder = PageFolder.find(id)
        folder.page_folder = page_archive_folder
        folder.save!
      elsif type == "page"
        page = Page.find(id)
        page.page_folder = page_archive_folder
        page.save!
      end
      {message: "#{type.capitalize} archived successfully."}
    end
  end
end
