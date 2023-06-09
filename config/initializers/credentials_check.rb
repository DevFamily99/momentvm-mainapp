# frozen_string_literal: true

errors = []
unless Rails.application.credentials.dig(ENV['CURRENT_INSTANCE']&.to_sym || :local, :mainapp, :momentvm_preview_url)
  errors.push('default momentvm preview wrapper url not in credentials')
end

unless Rails.application.credentials.dig(ENV['CURRENT_INSTANCE']&.to_sym || :local, :mainapp, :preview_selector)
  errors.push('default momentvm preview selector not in credentials')
end

unless Rails.application.credentials.dig(ENV['CURRENT_INSTANCE']&.to_sym || :local, :mainapp, :momentvm_client_id)
  errors.push('default momentvm client id not in credentials')
end

unless Rails.application.credentials.dig(ENV['CURRENT_INSTANCE']&.to_sym || :local, :mainapp, :momentvm_secret_key)
  errors.push('default momentvm secret key not in credentials')
end

unless Rails.application.credentials.dig(ENV['CURRENT_INSTANCE']&.to_sym || :local, :mainapp, :captcha_site_key)
  errors.push('captcha site key not in credentials')
end

unless Rails.application.credentials.dig(ENV['CURRENT_INSTANCE']&.to_sym || :local, :mainapp, :captcha_secret_key)
  errors.push('captcha secret key not in credentials')
end

unless Rails.env.test?
  raise Exception, errors unless errors.empty?
end
