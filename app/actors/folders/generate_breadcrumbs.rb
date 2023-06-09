module Folders
  #  Generates breadcrumbs for a folder
  class GenerateBreadcrumbs < Actor
    input :folder, allow_nil: false

    output :breadcrumbs

    def call
      self.breadcrumbs = []
      return unless folder.parent_folder

      self.breadcrumbs = iterate_nested(folder, [])
    end

    def iterate_nested(folder, crumbs)
      if folder.parent_folder
        path = folder.parent_folder.path
        path = '/page_folders' if folder.parent_folder.root? && folder.instance_of?(PageFolder)
        path = '/assets' if folder.parent_folder.root? && folder.instance_of?(AssetFolder)
        crumbs.unshift({ id: folder.parent_folder.id, __typename: 'PageFolder', name: folder.parent_folder.name, path: path })
        iterate_nested(folder.parent_folder, crumbs)
      end
      crumbs
    end
  end
end
