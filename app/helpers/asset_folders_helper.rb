module AssetFoldersHelper

  def asset_breadcrumb(asset_folder)
    nested = [asset_folder]
    list = iterate_asset_folders(nested, asset_folder).reverse
    return list
  end

  def iterate_asset_folders(nested, asset_folder)
    parent_folder = asset_folder.asset_folder
    unless parent_folder.nil?
      nested << parent_folder
      iterate_asset_folders(nested, parent_folder)
    else
      return nested
    end
  end

end
