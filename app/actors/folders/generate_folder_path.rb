module Folders
  #  Generates a folders path out of slugs
  class GenerateFolderPath < Actor
    input :folder, allow_nil: false

    output :path

    def call
      path = iterate_nested(folder, folder.slug)
      self.path = "/#{path}"
    end

    def iterate_nested(folder, path)
      return path unless folder.parent_folder

      one_up_path = "#{folder.parent_folder.slug}/#{path}"
      one_up_path = "page_folders/#{path}" if folder.parent_folder.root? && folder.instance_of?(PageFolder)
      one_up_path = "assets/#{path}" if folder.parent_folder.root? && folder.instance_of?(AssetFolder)
      iterate_nested(folder.parent_folder, one_up_path) if folder.parent_folder
    end
  end
end
