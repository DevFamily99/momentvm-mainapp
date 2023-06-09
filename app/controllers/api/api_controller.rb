# frozen_string_literal: true

module Api
  # All api controllers should inherit from this
  class ApiController < ActionController::API
    include ActionController::MimeResponds
    
    before_action :require_token

    private

    def require_token
      return render json: { error: 'Auth token missing' }, status: :forbidden unless request.headers['apiToken']

      begin
        decoded_token = JWT.decode request.headers['apiToken'], Rails.application.credentials.secret_key_base, true, { algorithm: 'HS512' }
        @current_user = User.find(decoded_token[0]['user_id'])
      rescue StandardError
        render json: { error: 'Token verification error' }, status: :forbidden
      end
    end
  end
end
