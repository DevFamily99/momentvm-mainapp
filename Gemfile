# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end
gem 'friendly_id', '~> 5.2.4'
# Only for ENV in tests
gem 'dotenv-rails', groups: [:test]

gem 'service_actor'

gem 'attr_encrypted'

gem 'net-smtp'

gem 'pg_search'

# Colored console output
gem 'rainbow'

gem 'rack-cors'

# Background tasks
# Run locally with bundle exec sidekiq
# Start redis with redis-server
gem 'sidekiq'

gem 'graphiql-rails', group: :development
# Uses https://github.com/rmosolgo/graphql-ruby
# Dont be confused this is called graphql-ruby on github
gem 'graphql'
# Needed for action cable redis usage
gem 'redis', '~> 4.0'

# Active Storage Variants
# gem 'mini_magick' deprecated
gem 'image_processing', '~> 1.0'

gem 'paper_trail'

# Active Storage
gem 'aws-sdk-s3', require: false

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.0'

gem 'honeybadger'
gem 'jwt'

gem 'pg'

# Use Puma as the app server
gem 'puma', '~> 6.0'
# Use SCSS for stylesheets
# gem 'sassc-rails'
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'bootsnap'

gem 'redcarpet'

gem 'rubyzip'

gem 'pry', group: :development

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Pagination
gem 'will_paginate'
# sFTP
gem 'net-sftp'
# gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false
# Sorcery for Authentication
gem 'sorcery'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Rake tasks
gem 'faker'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rb-readline'
  gem 'simplecov'
  # YAML dumps
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'guard-rspec', require: false
  gem 'htmlbeautifier'
  gem 'rspec-rails'
  gem 'rubocop', '~> 0.89', require: false
  gem 'rubocop-rails', '~> 2.5', require: false
  gem 'rubocop-rspec', '~> 1.39', require: false
  gem 'yaml_db'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'solargraph'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'webdrivers'
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
