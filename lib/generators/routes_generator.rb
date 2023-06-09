# frozen_string_literal: true

# lib/generators/routes_generator.rb
# run it with: rails generate routes
# WARNING: It is not recommended to run this manually, we switched to erb-loader
class RoutesGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file 'app/webpacker/routes.js', JsRoutes.generate
  end
end
