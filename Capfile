# DataDog deployment events
require "capistrano/datadog"
set :datadog_api_key, "5a2b3ffdb12de3ae0f25b12610457dbb"

# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
#require 'capistrano/slack'
require 'capistrano/sidekiq'
require 'capistrano/passenger'
# Load custom tasks from `lib/capistrano/tasks` if you have any defined
require 'capistrano/maintenance'
require 'whenever/capistrano'
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
