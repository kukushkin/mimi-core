# frozen_string_literal: true

module Mimi
  module Core
    #
    # Manifest represents a set of definitions of configurable parameters.
    #
    # It is a way of formally declaring which configurable parameters are accepted by a Mimi module,
    # application etc. A Manifest object is also used to validate passed set of raw values,
    # apply rules and produce a set of parsed configurable parameter values.
    #
    # Manifests are constructed from a Hash representation, following some structure.
    # Configurable parameter definitions are specified in the manifest Hash as
    # key-value pairs, where *key* is the name of the configurable parameter, and
    # *value* is a Hash with parameter properties.
    #
    # Example:
    #
    # ```ruby
    # manifest = Mimi::Core::Manifest.new(
    #   var1: {}, # minimalistic configurable parameter definition, all properties are default
    #   var2: {}
    # )
    # ```
    #
    # The properties that can be defined for a configurable parameter are:
    #
    # * `:desc` (String) -- a human readable description of the parameter (default: nil)
    # * `:type` (Symbol,Array<String>) -- defines the type of the parameter and the type/format
    #   of accepted values (default: :string)
    # * `:default` (Object) -- specified default value indicates that the parameter is optional
    # * `:hidden` (true,false) -- if set to true, omits the parameter from the application's
    #   combined manifest
    # * `:const` (true,false) -- if set to true, this configurable parameter cannot be changed
    #     and always equals to its default value which must be specified
    #
    # ## Configurable parameter properties
    #
    # ### :desc => <String>
    #
    # Default: `nil`
    #
    # Allows to specify a human readable description for a configurable parameter.
    #
    # Example:
    #
    # ```ruby
    # manifest = Mimi::Core::Manifest.new(
    #   var1: {
    #     desc: 'My configurable parameter 1'
    #   }
    # }
    # ```
    #
    #
    # ### :type => <Symbol,Array<String>>
    #
    # Default: `:string`
    #
    # Defines the type of the parameter and accepted values. Recognised types are:
    #
    # * `:string` -- accepts any value, presents it as a `String`
    # * `:integer` -- accepts any `Integer` value or a valid `String` representation of integer
    # * `:decimal` -- accepts `BigDecimal` value or a valid `String` representation
    #   of a decimal number
    # * `:boolean` -- accepts `true` or `false` or string literals `'true'`, `'false'`
    # * `:json` -- accepts a string with valid JSON, presents it as a parsed object
    #   (literal, Array or Hash)
    # * `Array<String>` -- defines enumeration of values, e.g. `['debug', 'info', 'warn', 'error']`;
    #   only values enumerated in the list are accepted, presented as `String`
    #
    # Example:
    #
    # ```ruby
    # manifest = Mimi::Core::Manifest.new(
    #   var1: {
    #     type: :integer,
    #     default: 1
    #   },
    #
    #   var2: {
    #     type: :decimal,
    #     default: '0.01'
    #   },
    #
    #   var3: {
    #     type: ['debug', 'info', 'warn', 'error'],
    #     default: 'info'
    #   }
    # }
    # ```
    #
    # ### :default => <Object, Proc>
    #
    # Default: `nil`
    #
    # ...
    #
    # ### :hidden => <true,false>
    #
    # Default: `false`
    #
    # ...
    #
    # ### :const => <true,false>
    #
    # Default: `false`
    #
    # ...
    #
    #
    # Example:
    #   manifest_hash = {
    #     var1: {
    #       desc: 'My var 1',
    #       type: :string,
    #
    #     }
    #   }
    #
    class Manifest
      ALLOWED_TYPES = %w[string integer decimal boolean json].freeze

      attr_reader :manifest

      # Constructs a new Manifest from its Hash representation
      #
      # @param manifest_hash [Hash,nil] default is empty manifest
      #
      def initialize(manifest_hash = {})
        self.class.validate_manifest_hash(manifest_hash)
        @manifest = manifest_hash.deep_dup
      end

      # Validates a Hash representation of the manifest
      #
      # * all keys are symbols
      # * all configurable parameter properties are valid
      #
      # @param manifest_hash [Hash]
      # @raise [ArgumentError] if any part of manifest is invalid
      #
      def self.validate_manifest_hash(manifest_hash)
        invalid_keys = manifest_hash.keys.reject { |k| k.is_a?(Symbol) }
        unless invalid_keys.empty?
          raise ArgumentError,
            "Invalid manifest keys, Symbols are expected: #{invalid_keys.join(', ')}"
        end

        manifest_hash.each { |n, p| validate_manifest_key_properties(n, p) }
      end

      # Validates configurable parameter properties
      #
      # @param name [Symbol] name of the parameter
      # @param properties [Hash] configurable parameter properties
      #
      def self.validate_manifest_key_properties(name, properties)
        raise 'Hash as properties is expected' unless properties.is_a?(Hash)
        if properties[:desc]
          raise ArgumentError, 'String as :desc is expected' unless properties[:desc].is_a?(String)
        end
        if properties[:type]
          if properties[:type].is_a?(Array)
            if properties[:type].any? { |v| !v.is_a?(String) }
              raise ArgumentError, 'Array<String> is expected as enumeration :type'
            end
          elsif !ALLOWED_TYPES.include?(properties[:type].to_s)
            raise ArgumentError, "Unrecognised type '#{properties[:type]}'"
          end
        end
        if properties.keys.include?(:hidden)
          if !properties[:hidden].is_a?(TrueClass) && !properties[:hidden].is_a?(FalseClass)
            raise ArgumentError, 'Invalid type for :hidden, true or false is expected'
          end
        end
        if properties.keys.include?(:const)
          if !properties[:const].is_a?(TrueClass) && !properties[:const].is_a?(FalseClass)
            raise ArgumentError, 'Invalid type for :const, true or false is expected'
          end
        end
        if properties[:const] && !properties.keys.include?(:default)
          raise ArgumentError, ':default is required if :const is set'
        end
      rescue ArgumentError => e
        raise ArgumentError, "Invalid manifest: invalid properties for '#{name}': #{e}"
      end
    end # class Manifest
  end # module Core
end # module Mimi
