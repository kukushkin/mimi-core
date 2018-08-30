# frozen_string_literal: true

module Mimi
  module Core
    module InheritableProperty
      def self.included(base)
        base.send :extend, ClassMethods
      end

      module ClassMethods
        def inheritable_property(name, opts = {})
          unless name.is_a?(Symbol)
            raise ArgumentError, 'Symbol is expected as inheritable_property name'
          end
          var_name = "@#{name}".to_sym
          opts_default = opts[:default] && opts[:default].dup
          define_singleton_method(name) do |*args|
            # puts "#{self.name}.#{name}(#{args.inspect})"
            arg = args.first
            if args.size > 0
              # puts "#{self.name}.#{name} = #{arg.inspect}"
              if opts[:type] == :hash && !arg.is_a?(Hash) && !arg.nil?
                raise ArgumentError, "Hash or nil is expected as a value for property #{self}.#{name}"
              end
              instance_variable_set(var_name, arg)
            elsif opts[:type] == :hash
              # combine this class' value with a superclass' value
              self_value = instance_variable_get(var_name) || {}
              super_value =
                (superclass.respond_to?(name) && superclass.send(name)) ||
                (opts_default.is_a?(Proc) ? opts_default.call : opts_default)
              super_value.deep_merge(self_value)
            else
              instance_variable_get(var_name) ||
              (superclass.respond_to?(name) && superclass.send(name)) ||
              (opts_default.is_a?(Proc) ? opts_default.call : opts_default)
            end
          end

          define_singleton_method("#{name}!".to_sym) do
            send(name) || (raise "Property #{self}.#{name} is not set")
          end
        end
      end # module ClassMethods
    end # module InheritableProperty
  end # module Core
end # module Mimi