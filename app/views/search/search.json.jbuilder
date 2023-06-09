json.array! @results do |result|
  json.id result.searchable_id
  json.type result.searchable_type
  json.content result.content
  if result.searchable_type == "Page"
    json.url page_path(result.searchable)
    json.folder_name result.searchable.page_folder.name
  end
  if result.searchable_type == "Asset"
    json.url asset_path(result.searchable)
    json.folder_name result.searchable.asset_folder.name
  end
  if result.searchable_type == "Template"
    json.url template_path(result.searchable)
  end

end
