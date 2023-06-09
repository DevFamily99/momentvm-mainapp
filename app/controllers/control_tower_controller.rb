require 'render_service_request'
class ControlTowerController < ApplicationController
  def health_check
    req = RenderServiceRequest.new
    req.url = ENV.fetch('RENDER_SERVICE_URL')
    req.user = ENV.fetch('RENDER_SERVICE_USERNAME')
    req.password = ENV.fetch('RENDER_SERVICE_PASSWORD')
    req.get_version do |_res_code, response|
      render json: response.body
    end
  end
end
