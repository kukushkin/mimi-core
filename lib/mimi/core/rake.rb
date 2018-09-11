# frozen_string_literal: true

# When required, `mimi/core/rake` loads all rake tasks exported by *loaded* modules
# and current application (found under `app_root_path`).
#
# Usage:
#
# ```ruby
# # lib/my_app.rb
# require 'mimi/core'
# require 'mimi/db'
#
#
# # lib/tasks/my_task.rake
# desc 'My application task'
# task :my_task do
#   puts
# end
#
#
# # Rakefile
# require_relative 'lib/my_app'
# require 'mimi/core/rake'
# ```
#
# This makes rake tasks exported by `mimi-db` and other loaded modules available:
#
# ```ruby
# $ rake -T
# rake db:clear                   # Clear database
# rake db:config                  # Show database config
# rake db:create                  # Create database
# ...
# rake my_task                    # My application task
# ```
#
#
module Mimi
  module Core
    #
    # Mimi::Core::Rake module contains various rake helpers
    #
    module Rake
      #
      # Loads rake tasks exported by *loaded* modules
      #
      def self.load_rake_tasks
        unless Mimi.respond_to(:app_root_path)
          raise 'Cannot load rake tasks before mimi-core module is loaded'
        end
        app_and_modules_paths = [Mimi.app_root_path] + Mimi.loaded_modules_paths
        rakefiles = app_and_modules_paths.map do |path|
          Pathname.glob(path.join('lib', 'tasks', '**', '*.rake'))
        end.flatten
        rakefiles.each do |rakefile|
          load rakefile
        end
      end
    end # module Rake
  end # module Core
end # module Mimi

Mimi::Core::Rake.load_rake_tasks if defined?(Mimi::Core::Module)
