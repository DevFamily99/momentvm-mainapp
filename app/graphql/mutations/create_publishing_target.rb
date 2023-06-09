class Mutations::CreatePublishingTarget < GraphQL::Schema::RelayClassicMutation
  argument :name, String, required: true
  argument :publishing_url, String, required: true
  argument :catalog, String, required: false
  argument :default_library, String, required: false
  argument :webdav_username, String, required: false
  argument :webdav_password, String, required: false
  argument :webdav_path, String, required: false
  argument :preview_url, String, required: false

  field :publishing_target, Types::PublishingTargetType, null: true
  field :errors, [String], null: false

  def resolve(params)
    publishing_target = PublishingTarget.new
    publishing_target.name = params[:name] 
    publishing_target.publishing_url = params[:publishing_url] if params[:publishing_url]
    publishing_target.catalog = params[:catalog] if params[:catalog]
    publishing_target.default_library = params[:default_library] if params[:default_library]
    publishing_target.webdav_username = params[:webdav_username] if params[:webdav_username]
    publishing_target.webdav_password = params[:webdav_password] if params[:webdav_password]
    publishing_target.webdav_path = params[:webdav_path] if params[:webdav_path]
    publishing_target.preview_url = params[:preview_url] if params[:preview_url]
    current_user = context[:current_user]
    publishing_target.team = current_user.team

    if publishing_target.save
      {
        publishing_target: publishing_target
      }
    else
      raise publishing_target.errors.full_messages.join
    end
  end
end
