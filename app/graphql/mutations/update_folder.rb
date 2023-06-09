class Mutations::UpdateFolder < GraphQL::Schema::RelayClassicMutation
  argument :folder_id, ID, required: true
  argument :name, String, required: false
  argument :folder_type, String, required: false

  field :message, String, null: true

  def resolve(input)
    if input[:folder_type] == 'AssetFolder'
      folder = AssetFolder.find(input[:folder_id])
      folder.name = input[:name]
    end
    if input[:folder_type] == 'PageFolder'
      folder = PageFolder.find(input[:folder_id])
      folder.name = input[:name]
    end

    if folder.save
      folder.generate_path
      folder.save!
      {
        message: 'Folder updated.'
      }
    else
      raise folder.errors.full_messages.join
    end
  end
end
