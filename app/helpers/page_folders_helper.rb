module PageFoldersHelper

  def breadcrumb(page_folder)
    nested = [page_folder]
    list = iterate_folders(nested, page_folder).reverse
    return list
  end

  def iterate_folders(nested, page_folder)
    parent_folder = page_folder.page_folder

    if parent_folder == nil
      return nested
    end

    if parent_folder == parent_folder.page_folder
      parent_folder.page_folder = nil
      parent_folder.save
      return nested
    end
    nested << parent_folder
    iterate_folders(nested, parent_folder)
	end
end
