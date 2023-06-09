# Handles the OAuth2 token with SFCC

# Exposes get_token which is a synchronous method to receive a token
# Returns a Token object
# Handles non-expired tokens without additional request

require 'request'

class TokenRequest < Request

  class CouldNotRetrieveTokenError < StandardError
    def initialize(msg = "Token could not be retrieved")
      super
    end
  end

  class_attribute :path, default: "/token/get"


    # Returns a Token or nil
    def get_token(team:)
      req = Request.new
      req.send_request(
        url: Rails.configuration.url_publishing_service + self.path,
        header: {
          "Client-ID": team.client_id,
          "Client-Secret": team.client_secret
        },
        options: {
          username: Rails.configuration.user_publishing_service,
          password: Rails.configuration.password_publishing_service
        }
      ) do |response_code, response|
        if response_code == 400
          raise CouldNotRetrieveTokenError
        end
        parsed = JSON.parse(response.body)
        token = parsed["access_token"]
        return token
      end
    end



end
