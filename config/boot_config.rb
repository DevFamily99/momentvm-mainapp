require 'rainbow/refinement'

# Custom Boot Config for micro services setup
class BootConfig
  using Rainbow
  class BootError < StandardError; end

  # Entry point
  def self.add_custom_boot_config_for(config)
    puts "Loading custom boot config...".green
    # If in console
    unless Rails.const_defined? 'Server'
      config.s3 = {
        access_key_id: '',
        secret_access_key: '',
        region: '',
        bucket: ''
      }
    end
    if Rails.env.test?
      ENV['RENDER_INSTANCE'] = 'local'
      ENV['TRANSLATION_INSTANCE'] = 'local'
      ENV['S3_INSTANCE'] = 'local'
      ENV['PROXY_INSTANCE'] = 'local'
      ENV['PUBLISH_INSTANCE'] = 'local'
    end

    unless load_env
      # In rails console ENV variables are not loaded so we need to load them manually
      require 'dotenv'
      Dotenv.load
      puts 'Custom Boot error. '.red + 'One of the Configs is missing. This error is only critical if triggered by a server environment' unless load_env
    end
    # basic_auth(config)
    renderer(config)
    translation_service(config)
    proxy_service(config)
    publish_service(config)
    configure_s3(config)
    puts 'Successfully loaded custom boot config'.green
  end

  # Check if env variables were loaded correctly otherwise you can manually invoce Dotenv load
  def self.load_env
    @render_instance = ENV['RENDER_INSTANCE']
    @translation_instance = ENV['TRANSLATION_INSTANCE']
    @s3_instance = ENV['S3_INSTANCE']
    @proxy_instance = ENV['PROXY_INSTANCE']
    @publish_instance = ENV['PUBLISH_INSTANCE']
    if @render_instance.nil? || @translation_instance.nil? || @s3_instance.nil? || @proxy_instance.nil? || @publish_instance.nil?
      false
    else
      true
    end
  end

  def self.basic_auth(config)
    if ENV['BASIC_AUTH_USERNAME'].nil? || ENV['BASIC_AUTH_USERNAME'].nil? || ENV['BASIC_AUTH_PASSWORD'].nil?
      puts 'No basic auth'
      raise BootConfig, 'BASIC_AUTH_USERNAME in ENV is nil'
    end
    puts 'Booting with basic auth'
    config.basic_auth = {
      username: ENV['BASIC_AUTH_USERNAME'],
      password: ENV['BASIC_AUTH_PASSWORD']
    }
  end

  def self.renderer(_config)
    # raise BootError, 'RENDER_INSTANCE not defined' if @render_instance.nil?

    # config.render_service = {
    #   url: Rails.application.credentials.dig(@render_instance.to_sym, :render_service, :url),
    #   username: Rails.application.credentials.dig(@render_instance.to_sym, :render_service, :username),
    #   password: Rails.application.credentials.dig(@render_instance.to_sym, :render_service, :password)
    # }
    # # Production passwords are not stored in git
    # # They need to be added via ENV variable
    # config.render_service[:password] = ENV['RENDER_SERVICE_BASIC_AUTH_PASSWORD'] if @render_instance == 'production'
    # puts "RENDER SERVICE connects to #{config.render_service[:url].green}"
  end

  def self.translation_service(config)
    raise BootError, 'Error: Set TRANSLATION_INSTANCE in .env' if @translation_instance.nil?

    config.translation_service = {
      url: Rails.application.credentials.dig(@translation_instance.to_sym, :translation_service, :url),
      username: Rails.application.credentials.dig(@translation_instance.to_sym, :translation_service, :username),
      password: Rails.application.credentials.dig(@translation_instance.to_sym, :translation_service, :password)
    }

    # Override translation service url
    unless ENV['TRANSLATION_SERVICE_URL'].nil?
      config.translation_service[:url] = ENV['TRANSLATION_SERVICE_URL']
    end
    # Production passwords are not stored in git
    # They need to be added via ENV variable
    config.translation_service[:password] = ENV['TRANSLATION_SERVICE_BASIC_AUTH_PASSWORD'] if @translation_instance == 'production'
    puts "TRANSLATION SERVICE connects to #{config.translation_service[:url]&.green || 'Nothing'.bg(:red)}"
  end

  def self.proxy_service(config)
    raise BootError, 'PROXY_INSTANCE nil in ENV' if @proxy_instance.nil?

    config.proxy_service = {
      url: Rails.application.credentials.dig(@proxy_instance.to_sym, :proxy_service, :url),
      username: Rails.application.credentials.dig(@proxy_instance.to_sym, :proxy_service, :username),
      password: Rails.application.credentials.dig(@proxy_instance.to_sym, :proxy_service, :password)
    }
    # Production passwords are not stored in git
    # They need to be added via ENV variable
    config.proxy_service[:password] = ENV['PROXY_SERVICE_BASIC_AUTH_PASSWORD'] if @proxy_instance == 'production'
    puts "PROXY SERVICE connects to #{config.proxy_service[:url]&.green || 'Nothing'.bg(:red)}"
  end

  def self.publish_service(config)
    raise BootError, 'PUBLISH_INSTANCE nil in ENV' if @publish_instance.nil?

    config.publishing_service = {
      url: Rails.application.credentials.dig(@publish_instance.to_sym, :publishing_service, :url),
      username: Rails.application.credentials.dig(@publish_instance.to_sym, :publishing_service, :username),
      password: Rails.application.credentials.dig(@publish_instance.to_sym, :publishing_service, :password)
    }

    # Production passwords are not stored in git
    # They need to be added via ENV variable
    config.publishing_service[:password] = ENV['PUBLISHING_SERVICE_BASIC_AUTH_PASSWORD'] if @publish_instance == 'production'
    puts "PUBLISH SERVICE connects to #{config.publishing_service[:url]&.green || 'Nothing'.bg(:red) || 'Nothing'.bg(:red)}"
  end

  def self.configure_s3(config)
    # S3
    # Will respect the .env files setting: ["local", "release", "production"]
    raise BootError, 'S3_INSTANCE nil in ENV' if @s3_instance.nil?

    if @s3_instance == 'local'
      configure_active_storage_local(config)
    else
      configure_active_storage_cloud(config)
    end
  end

  private_class_method def self.configure_active_storage_local(config)
    config.active_storage.service = :local

    config.s3 = {
      access_key_id: '',
      secret_access_key: '',
      region: '',
      bucket: ''
    }
    puts 'S3 configured to run ' + 'locally'.green
  end

  private_class_method def self.configure_active_storage_cloud(config)
    config.active_storage.service = :amazon

    config.s3 = {
      access_key_id: Rails.application.credentials.dig(@s3_instance.to_sym, :s3, :access_key_id),
      secret_access_key: Rails.application.credentials.dig(@s3_instance.to_sym, :s3, :secret_access_key),
      region: Rails.application.credentials.dig(@s3_instance.to_sym, :s3, :region),
      bucket: Rails.application.credentials.dig(@s3_instance.to_sym, :s3, :bucket)
    }
    # Production passwords are not stored in git
    # They need to be added via ENV variable
    config.s3[:secret_access_key] = ENV['S3_ACCESS_SECRET'] if @s3_instance == 'production'
    puts "S3 configured to bucket #{config.s3[:bucket]&.yellow || 'Nothing'.bg(:red)}"
  end
end
