source 'https://rubygems.org'

gem 'rails', '3.2.22'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'activeuuid', '>= 0.5.0'
gem 'pg_array_parser'
gem 'activerecord-postgres-hstore'
gem 'nested-hstore'
gem 'pg_search', '~> 0.5.7'
gem 'foreigner'
gem 'oj' #optimised JSON (picked by multi_json)
gem 'nokogiri'
gem 'inherited_resources'
gem 'traco', '~> 2.0.0'
gem 'strong_parameters'
gem 'devise'
gem 'cancan'
gem 'ahoy_matey'
gem 'gon'
gem 'wicked'
gem 'groupdate'
gem "chartkick"

gem 'sidekiq', '~> 3.4.2'
gem 'sidekiq-status', '~> 0.5.4'

gem 'whenever', :require => false

gem 'ember-rails'
gem 'ember-source', '1.1.2'
gem 'jquery-rails', '2.1.4' #do not upgrade until https://github.com/jquery/jquery/pull/1142 isd pulled into jquery-rails
gem 'jquery-mousewheel-rails'
gem 'jquery-cookie-rails'
gem 'bootstrap-sass', '~> 2.3.1.0'
gem 'kaminari'
gem 'select2-rails', '~> 3.5.7'
gem 'nested_form', '~> 0.3.2'
gem 'acts-as-taggable-on', '~> 2.3.1'
gem 'carrierwave'

gem 'underscore-rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem "susy"
  gem 'compass', '>= 0.12.2'
  gem 'compass-rails', '>= 1.0.3'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'


# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :staging, :production do
  gem 'exception_notification', :git => 'https://github.com/smartinez87/exception_notification.git'
  gem 'slack-notifier', '~> 1.0'
end

gem 'rest_client', require: false

group :development do
  gem "better_errors", '~>1.1.0'
  gem "binding_of_caller", '>=0.7.2'
  gem 'immigrant'
  gem "guard-livereload"
  gem "yajl-ruby"
  gem "rack-livereload"
  gem "guard-bundler"
  gem 'annotate', ">=2.5.0"
  gem 'sextant'
  # Deploy with Capistrano
  gem 'capistrano', '~> 3.4', require: false
  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm',   '~> 0.1', require: false
  gem 'capistrano-sidekiq'
  gem 'capistrano-maintenance', '~> 1.0', require: false
  gem 'capistrano-passenger', '~> 0.1.1', require: false
  gem 'slackistrano', require: false
  gem 'brightbox', '>=2.3.9'
  gem 'rack-cors', :require => 'rack/cors'
  gem 'quiet_assets'
  gem 'webrick', '1.3.1'
  gem 'jslint_on_rails'
  gem 'git_pretty_accept'
  gem 'dogapi', '>= 1.3.0'
end

group :test, :development do
  gem "rspec-rails"
  gem "rspec-mocks"
  gem "json_spec"
  gem "database_cleaner", ">=1.2.0"
  gem "timecop"
  gem "launchy"
  gem 'byebug'
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem "factory_girl_rails", "~> 4.0"
  gem 'simplecov', :require => false
  gem 'coveralls', :require => false
  gem 'capybara'
end

gem 'rake', '~> 10.0.3'

gem 'slim'
# if you require 'sinatra' you get the DSL extended to Object
gem 'sinatra', '>= 1.3.0', :require => nil

gem 'memcache-client'
#gem 'high_voltage'

gem 'jquery-ui-rails'

gem 'geoip'

#track who created or edited a given object
gem 'clerk'
gem 'paper_trail', '~> 4.0.0.beta'

gem 'rails-secrets'

gem 'test-unit', '~> 3.1' # annoyingly, rails console won't start without it in staging / production
