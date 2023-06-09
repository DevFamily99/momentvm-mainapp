Rails.application.config.active_storage.service_urls_expire_in = 1.hour
ActiveStorage::Engine.config.active_storage.content_types_to_serve_as_binary.delete('image/svg+xml')

