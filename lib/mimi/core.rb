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
      used_modules << mod unless used_modules.include?(mod)
    end

    # Returns the list of loaded (require-d) modules
    #
    def loaded_modules
      @loaded_modules ||= []
    end

    # Returns the list of used modules
    #
    def used_modules
      @used_modules ||= []
    end

    # Returns all loaded module paths, which are defined (non nil)
    #
    def loaded_modules_paths
      loaded_modules.map(&:module_path).reject(&:nil?)
    end

    # Requires all files that match the glob.
    #
    def require_files(glob, root_path = app_root_path)
      Pathname.glob(root_path.join(glob)).each do |filename|
        require filename.expand_path
      end
    end

    # Starts all used modules in the ascending order
    #
    def start
      used_modules.each { |m| m.start unless m.started? }
    end

    # Stops all used modules in the reversed order
    #
    def stop
      used_modules.reverse.each { |m| m.stop if m.started? }
    end
  end # module Core

  # make Core methods available at top-level
  extend Core
end # module Mimi

require_relative 'core/version'
require_relative 'core/module'
require_relative 'core/core_ext'
