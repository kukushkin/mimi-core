# frozen_string_literal: true

module Mimi
  module Core
    #
    # Makes `.inheritable_property` method available to the class.
    #
    # Example:
    #
    # ```
    # class A
    #   include Mimi::Core::InheritableProperty
    #
    #   inheritable_property :my_var
    # end
    # ```
    # @see Mimi::Core::InheritableProperty::ClassMethods#inheritable_property
    #
    module InheritableProperty
      def self.included(base)
        base.send :extend, ClassMethods
      end

      module ClassMethods
        #
        # Declares an inheritable property.
        #
        # The inheritable property is a special class variable, that is accessible
        # in descendant classes, but each of the descendant classes can alter only its local value.
        #
        # Once a property is declared, a class method with the name of the property
        # becomes available.
        #
        # ```
        # class A
        #   include Mimi::Core::InheritableProperty
        #
        #   inheritable_property :var1, default: 1
        # end
        #
        # class B < A
        # end
        #
        # A.var1 # => 1
        # B.var1 # => 1
        # ```
        #
        # A class method with the name of the property accepts one optional argument -- a new value
        # for the property. If the argument is omitted, current inherited value is returned.
        #
        # If the argument is present, it sets a new property value for this class
        # and its subclasses, but not for the parent class.
        #
        # ```
        # class A
        #   include Mimi::Core::InheritableProperty
        #
        #   inheritable_property :var1, default: 1
        # end
        #
        # class B < A
        #   var1 123 # sets new value for B.var1
        # end
        #
        # class C < B
        # end
        #
        # A.var1 # => 1, the default value, unchanged
        # B.var1 # => 123
        # C.var1 # => 123
        # ```
        #
        # Working with Hash values
        # ===
        # An `inherited_property` can be declared having the type `:hash`, then the inherited
        # values are deep-merged in subclasses.
        #
        # ```
        # class A
        #   include Mimi::Core::InheritableProperty
        #
        #   inheritable_property :var1, default: { a: 1 }
        # end
        #
        # class B < A
        #   var1 b: 2
        # end
        #
        # class C < B
        # end
        #
        # A.var1 # => { a: 1 }
        # B.var1 # => { a: 1, b: 2 }
        # C.var1 # => { a: 1, b: 2 }
        # ```
        #
        # Proc as default value
        # ===
        # A Proc can be specified instead of literal default value, in which case it will
        # be evaluated when the inherited property value is queried. The passed block will
        # be evaluated in the context of the current class.
        #
        # ```
        # class A
        #   include Mimi::Core::InheritableProperty
        #
        #   inheritable_property :var1, default: -> { self.name }
        # end
        #
        # class B < A
        # end
        #
        # class C < B
        # end
        #
        # A.var1 # => "A"
        # B.var1 # => "B"
        # ```
        #
        # @param name [Symbol] a name for the new inheritable property
        # @param opts [Hash,nil] optional parameters for the inheritable property
        # @option opts [Object,Proc] :default specifies the literal or Proc as the default value
        #   for the property
        # @option opts [:hash,nil] :type instructs that the property is a Hash or a simple value
        #   (inherited values are deep-merged for Hash'es)
        #
        def inheritable_property(name, opts = {})
          unless name.is_a?(Symbol)
            raise ArgumentError, 'Symbol is expected as inheritable_property name'
          end
          var_name = :"@#{name}"
          ip_get_name = :"inheritable_property_get_#{name}"
          ip_set_name = :"inheritable_property_set_#{name}"
          opts_default = opts[:default] && opts[:default].dup

          define_singleton_method(ip_get_name) do |caller|
            if opts[:type] == :hash
              # combine this class' value with a superclass' value
              self_value = instance_variable_get(var_name) || {}
              super_value =
                (superclass.respond_to?(ip_get_name) && superclass.send(ip_get_name, caller)) ||
                (opts_default.is_a?(Proc) ? caller.instance_exec(&opts_default) : opts_default)
              super_value.deep_merge(self_value)
            else
              instance_variable_get(var_name) ||
                (superclass.respond_to?(ip_get_name) && superclass.send(ip_get_name, caller)) ||
                (opts_default.is_a?(Proc) ? caller.instance_exec(&opts_default) : opts_default)
            end
          end

          define_singleton_method(ip_set_name) do |arg|
            if opts[:type] == :hash && !arg.is_a?(Hash) && !arg.nil?
              raise ArgumentError, "Hash or nil is expected as a value for property #{self}.#{name}"
            end
            instance_variable_set(var_name, arg)
          end

          define_singleton_method(name) do |*args|
            if args.empty?
              send(:"inheritable_property_get_#{name}", self)
            else
              send(:"inheritable_property_set_#{name}", args.first)
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
