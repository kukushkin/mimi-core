# frozen_string_literal: true

module Mimi
  module Core
    #
    # Mimi::Core::Struct is a simple immutable data structure.
    #
    # It allows instantiating an object from a set of attributes and makes them
    # available as object methods and Hash paramaters:
    #   my_object = Mimi::Core::Struct.new(a: 1, b: 2)
    #
    #   my_object.a    # => 1
    #   my_object[:a]  # => 1
    #   my_object['a'] # => 1
    #
    # It only allows access to defined attributes:
    #   my_object.c    # => NoMethodError
    #   my_object[:c]  # => NameError
    #
    class Struct
      #
      # Creates a Struct object from a set of attributes
      #
      # @param attrs [Hash]
      #
      def initialize(attrs = {})
        raise ArgumentError, "Hash is expected as attrs" unless attrs.is_a?(Hash)
        attributes = attrs.map { |k, v| [k.to_sym, v.dup] }.to_h
        initialize_attributes(attributes)
      end

      # Fetches attribute by its name
      #
      # @param name [String,Symbol]
      # @return [Object] attribute's value
      #
      def [](attr_name)
        attr_name = attr_name.to_sym
        unless @attributes.key?(attr_name)
          raise NameError, "undefined attribute #{attr_name.inspect}"
        end
        @attributes[attr_name]
      end

      # Returns Struct attributes as a Hash
      #
      # @return [Hash]
      #
      def to_h
        @attributes
      end

      # Compares two Structs, comparing only their attribute values
      #
      # @param other [Hash,Mimi::Core::Struct]
      # @return [true,false]
      #
      def ==(other)
        if !other.is_a?(Mimi::Core::Struct) && !other.is_a?(Hash)
          raise TypeError, "Cannot compare Mimi::Core::Struct and #{other.class}"
        end
        other_as_hash = other.is_a?(Hash) ? other : other.to_h
        self.to_h == other_as_hash
      end

      # Returns a new copy of a Mimi::Core::Struct object, deep copying its attributes
      #
      # @return [Mimi::Core::Struct]
      #
      def dup
        new_object = super
        new_object.send :initialize_attributes, @attributes
        new_object
      end

      private

      # Initializes attributes, defining access methods
      #
      # @param attributes [Hash]
      #
      def initialize_attributes(attributes)
        @attributes = attributes
        @attributes.keys.each do |attr_name|
          define_singleton_method(attr_name) { self[attr_name] }
        end
      end
    end # class Struct
  end # module Core
end # module Mimi
