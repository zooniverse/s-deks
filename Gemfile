# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# used for Azure active storage
gem 'azure-storage-blob'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem 'jbuilder'

# gem 'panoptes-client', '~> 1.1'
# TODO - this is what needs to happen next
# 1. publish the faraday-panoptes update
# 2. test the publish with a local FS gem changes to panoptes-client.rb
# 3. bump the panoptes-client.rb
# 4. patch this system and others if need be
# 5. should be able to use the minor version for the changes in both gems
gem 'panoptes-client', github: 'zooniverse/panoptes-client.rb', branch: 'relax-faraday-panoptes-constraint'
gem 'pg'
gem 'puma'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
gem 'rails', '~> 7.0'

# gem 'redis', '~> 4.0'
# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem 'kredis'

gem 'sidekiq'
gem 'strong_migrations'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem 'spring'
end

group :test do
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'webmock'
end
