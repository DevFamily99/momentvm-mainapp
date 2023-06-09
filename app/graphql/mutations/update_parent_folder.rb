class Mutations::UpdateParentFolder < GraphQL::Schema::RelayClassicMutation
  argument :target_id, ID, required: true
  argument :destination_id, ID, required: true
  argument :drop_type, String, required: true
  argument :folder_type, String, required: true

  field :message, String, null: false

  def resolve(params)
    if params[:folder_type] == 'AssetFolder'
      destination_folder = AssetFolder.find(params[:destination_id])
      if params[:drop_type] == 'folder'
        target = AssetFolder.find(params[:target_id])
        target.asset_folder_id = destination_folder.id
        if target.save
          target.generate_path
          target.save!
          return { message: 'Folder moved successfully' }
        else
          raise 'Failed to move'
        end
      elsif params[:drop_type] == 'asset'
        target = Asset.find(params[:target_id])
        target.asset_folder_id = destination_folder.id
        if target.save
          target.generate_path
          target.save!
          return { message: 'Asset moved successfully' }
        else
          raise 'Failed to move'
        end
      end
    end

    if params[:folder_type] == 'PageFolder'
      destination_folder = PageFolder.find(params[:destination_id])
      if params[:drop_type] == 'folder'
        target = PageFolder.find(params[:target_id])
        target.page_folder_id = destination_folder.id
        if target.save
          { message: 'Folder moved successfully' }
        else
          raise 'Failed to move'
        end
      elsif params[:drop_type] == 'page'
        target = Page.find(params[:target_id])
        target.page_folder_id = destination_folder.id
        if target.save
          { message: 'Page moved successfully' }
        else
          raise 'Failed to move'
        end
      end
    end
  end
end
