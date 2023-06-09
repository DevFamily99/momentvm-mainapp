Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  config.x.webpacker[:dev_server_host] = 'http://127.0.0.1:8080'
  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  ActionDispatch::Callbacks.after do
    # load 'filename_in_lib'
    # or
    Dir.entries("#{Rails.root}/lib").each do |entry|
      load entry if entry =~ /.rb$/
    end
  end

  # For local testing its best to use amazon. Nevertheless this will publish into
  # the actual development S3 bucket
  config.active_storage.service = ENV['S3_INSTANCE'] == 'local' ? :local : :amazon
  # Caching
  config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
  config.action_controller.perform_caching = true
  config.action_controller.enable_fragment_cache_logging = true

  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{2.days.to_i}"
  }

  # Use only in develop mode!
  config.action_cable.disable_request_forgery_protection = true
  # Running in app mode
  # config.action_cable.mount_path = '/cable'

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  Rails.application.routes.default_url_options[:host] = 'localhost'
  Rails.application.routes.default_url_options[:port] = '3000'
  # config.action_mailer.default_url_options = {:host => ENV["HOST"]}
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.perform_deliveries = true
  # config.action_mailer.smtp_settings = {
  #   :user_name => ENV["SENDGRID_USERNAME"],
  #   :password => ENV["SENDGRID_PASSWORD"],
  #   :domain => 'momentvm.com',
  #   :address => 'smtp.sendgrid.net',
  #   :port => 587,
  #   :authentication => :plain,
  #   :enable_starttls_auto => true
  # }
  config.action_mailer.default_url_options = { host: 'localhost' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }
  config.active_job.queue_adapter = :sidekiq
end
