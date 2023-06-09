module ApplicationCable
  class Connection < ActionCable::Connection::Base #:nodoc:
    identified_by :current_user
    rescue_from StandardError, with: :report_error

    def connect
      self.current_user = user_by_token
    end

    private

    def report_error(e)
      puts "Error in ws connection"
      puts e
    end

    def user_by_token
      token = request.params[:token]
      if token
        begin
          # puts "token exists for ApplicationCable connection"
          decoded_token = JWT.decode token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS512' }
          @current_user = User.find(decoded_token[0]['user_id'])
        rescue StandardError
          puts "couldnt parse token"
          reject_unauthorized_connection
        end

      else
        # puts "no token exists for ApplicationCable connection"
        reject_unauthorized_connection
      end
    end
  end
end
