source 'https://rubygems.org'

gem 'rails', '3.2.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'rails-api'

gem 'pg'
gem 'pg_array_parser'
gem 'activerecord-postgres-hstore'
gem 'foreigner'
gem 'immigrant'
gem 'awesome_nested_set'
gem 'exception_notification', :require => 'exception_notifier'

gem 'prawn'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'


# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development do
  gem "guard-livereload"
  gem "yajl-ruby"
  gem "rack-livereload"
  gem "guard-bundler"
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
  gem 'ruby-debug19'
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'brightbox', '>=2.3.9'
  gem 'rack-cors', :require => 'rack/cors'
end

gem "sqlite3", :group => [:test]

group :test, :development do
  gem "rspec-rails"
end

group :test do
  gem "factory_girl"
  gem "factory_girl_rails"
end
