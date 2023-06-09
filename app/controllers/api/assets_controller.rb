module Api
  class AssetsController < ApiController
    def upload
      count = 0
      asset_folder = if params[:asset_folder_id]
                       AssetFolder.find(params[:asset_folder_id])
                     else
                       AssetFolder.where(team_id: current_user.team_id, asset_folder_id: nil).first
                     end
      params[:images].each do |img|
        @asset = Asset.new
        @asset.asset_folder = asset_folder
        @asset.team_id = current_user.team_id
        @asset.image.attach(img)
        @asset.name = @asset.image.filename.to_s.parameterize(separator: '_')
        count += 1 if @asset.save
      end
      if count.positive?
        render json: { message: 'success' }, status: :created
      else
        render json: { error: @asset.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
