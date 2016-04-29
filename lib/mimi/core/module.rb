require 'active_support/concern'

module Mimi
  module Core
    module Module
      extend ActiveSupport::Concern

      class_methods do
        def configure(opts = {})
          @module_options = @module_default_options.deep_merge(opts)
          puts "** module #{self} configured"
        end

        def path
          p = Pathname.pwd.expand_path
          puts "** #{self}.lib_path: #{p}"
          p
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

        def module_options
          @module_options || {}
        end

        def default_options(opts = {})
          @module_default_options = opts
        end
      end
    end # module Module
  end # module Core
end # module Mimi
