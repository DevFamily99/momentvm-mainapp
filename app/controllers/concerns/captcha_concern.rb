# frozen_string_literal: true

module CaptchaConcern
  extend ActiveSupport::Concern

  def captcha_verify
    token = params['g-recaptcha-response'] || request.headers['Captcha-Token']
    url = URI.parse('https://www.google.com/recaptcha/api/siteverify')
    key = Rails.application.credentials.dig(ENV['CURRENT_INSTANCE']&.to_sym || :local, :mainapp, :captcha_secret_key)
    response = Net::HTTP.post_form(url, secret: key, response: token)
    body = JSON.parse(response.body)
    if body['success']
      redirect_to(:users, alert: 'You are a robot!') if body['score'] < 0.3
    else
      redirect_to(:users, alert: 'Captcha validation failed, please try again')
    end
  end
end
