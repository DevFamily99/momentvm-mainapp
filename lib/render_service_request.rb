require "request"

class RenderServiceRequest < Request

  class_attribute :url
  class_attribute :user
  class_attribute :password

  def get_version()
    self.send_request(
      url: self.url + "/version",
      options: {
        username: self.user,
        password: self.password
      }
    ) do |response_code, response|
      yield response_code, response
    end
  end


end