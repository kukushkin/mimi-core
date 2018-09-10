# frozen_string_literal: true

module Mimi
  module Core
    module Module
      #
      # Invoked on a descendant module declaration,
      # registers a descendant module in the list of loaded modules.
      #
      def self.included(base)
        return if Mimi.loaded_modules.include?(base)
        Mimi.loaded_modules << base
        base.send :extend, ClassMethods
      end

      module ClassMethods
        #
        # Processes given values for configurable parameters defined in the module manifest
        # and populates the options Hash.
        #
        # @param opts [Hash] values for configurable parameters
        #
        def configure(opts = {})
          manifest_hash = manifest
          unless manifest_hash.is_a?(Hash)
            raise "#{self}.manifest should be implemented and return Hash"
          end
          @options = Mimi::Core::Manifest.new(manifest_hash).apply(opts)
        end

        # Returns the path to module files, if the module exposes any files.
        #
        # Some modules may expose its files to the application using Mimi core. For example,
        # a module may contain some rake tasks with useful functionality.
        #
        # To expose module files, this method must be overloaded and point to the root
        # of the gem folder:
        #
        # ```
        # # For example, module my_lib folder and files:
        # /path/to/my_lib/
        #   ./lib/my_lib/...
        #   ./lib/my_lib.rb
        #   ./spec/spec_helper
        #   ...
        #
        # # my_lib module should expose its root as .module_path: /path/to/my_lib
        # ```
        #
        # @return [Pathname,String,nil]
        #
        def module_path
          nil
        end

        # Module manifest
        #
        # Mimi modules overload this method to define their own set of configurable parameters.
        # The method should return a Hash representation of the manifest.
        #
        # NOTE: to avoid clashes with other modules, it is advised that configurable parameters
        # for the module have some module-specific prefix. E.g. `Mimi::DB` module has its
        # configurable parameters names as `db_adapter`, `db_database`, `db_username` and so on.
        #
        # @see Mimi::Core::Manifest
        #
        # @return [Hash]
        #
        def manifest
          {}
        end

        # Starts the module.
        #
        # Mimi modules overload this method to implement some module-specific logic that
        # should happen on application startup. E.g. `mimi-messaging` establishes a connection
        # with a message broker and declares message consumers.
        #
        def start(*)
          @module_started = true
        end

        # Returns true if the module is started.
        #
        # @return [true,false]
        #
        def started?
          @module_started
        end

        # Starts the module.
        #
        # Mimi modules overload this method to implement some module-specific logic that
        # should happen on application shutdown. E.g. `mimi-messaging` closes a connection
        # with a message broker.
        #
        def stop(*)
          @module_started = false
        end

        # Returns a Hash of configurable parameter values accepted and set by the `.configure`
        # method.
        #
        # @return [Hash<Symbol,Object>]
        #
        def options
          @options || {}
        end
      end # module ClassMethods
    end # module Module
  end # module Core
end # module Mimi
