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
        def configure(opts = {})
          @options = {}.deep_merge(opts)
        end

        def module_path
          nil
        end

        def manifest
          {}
        end

        def start(*)
          @module_started = true
        end

        def started?
          @module_started
        end

        def stop(*)
          @module_started = false
        end

        def options
          @options || {}
        end
      end # module ClassMethods
    end # module Module
  end # module Core
end # module Mimi
