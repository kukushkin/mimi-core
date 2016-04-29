require 'pathname'

module Mimi
  module Core
    # Returns the application's root path.
    #
    # The root path is the current working directory by default.
    # If you need to use a different path as the app root path,
    # use #app_root_path=()
    #
    def app_root_path
      @app_root_path ||= Pathname.pwd.expand_path
    end

    # Sets the application's root path explicitly
    #
    def app_root_path=(path)
      @app_root_path = Pathname.new(path).expand_path
    end

    # Constructs the path relative to the application's root path.
    #
    # Example:
    #   Mimi.app_root_path # => /path/to/my_app
    #   Mimi.app_path_to('app', 'models') # => /path/to/my_app/app/models
    #
    def app_path_to(*args)
      app_root_path.join(*args)
    end

    # Use the given module
    #
    def use(mod, opts = {})
      raise ArgumentError, "#{mod} is not a Mimi module" unless mod < Mimi::Core::Module
      puts "** module #{mod} is used"
      mod.configure(opts)
      modules << mod
    end

    # Returns the list of registered (require-d) modules
    #
    def modules
      @modules ||= []
    end

    # Returns the list of used modules
    #
    def used_modules
      @used_modules ||= []
    end

    # Requires all files that match the glob.
    #
    def require_files(glob, root_path = app_root_path)
      Pathname.glob(root_path.join(glob)).each do |filename|
        require filename.expand_path
      end
    end
  end # module Core

  # make Core methods available at top-level
  extend Core
end # module Mimi

require_relative 'core/version'
require_relative 'core/module'
require_relative 'core/core_ext'
