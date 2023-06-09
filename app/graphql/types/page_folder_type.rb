module Types
  class PageFolderType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :path, String, null: false
    field :page_folders, [PageFolderType], null: true
    field :pages, Connections::PageConnection, null: true do
      argument :order, String, required: true
      argument :direction, String, required: true
    end
    field :root, Boolean, null: true
    field :is_archive, Boolean, null: true
    field :breadcrumbs, [GraphQL::Types::JSON], null: true

    def pages(order:, direction:)
      object.pages.order("#{order} #{direction}")
    end

    def root
      object.root?
    end

    def is_archive   
      page_archive_folder = PageFolder.find_or_create_by(name: 'Archive', team_id: context[:current_user].team_id)
      object.id == page_archive_folder.id
    end

    def breadcrumbs
      Folders::GenerateBreadcrumbs.call(folder: object).breadcrumbs
    end

    private

    def root_folder
      PageFolder.where(team_id: context[:current_user].team_id).where(page_folder_id: nil).first
    end
  end
end
