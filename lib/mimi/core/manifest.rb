# frozen_string_literal: true

require 'bigdecimal'
require 'json'

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

      # Constructs a new Manifest from its Hash representation
      #
      # @param manifest_hash [Hash,nil] default is empty manifest
      #
      def initialize(manifest_hash = {})
        self.class.validate_manifest_hash(manifest_hash)
        @manifest = manifest_hash_canonical(manifest_hash.deep_dup)
      end

      # Returns a Hash representation of the Manifest
      #
      # @return [Hash]
      #
      def to_h
        @manifest
      end

      # Merges current Manifest with another Hash or Manifest
      #
      # @param another [Mimi::Core::Manifest,Hash]
      #
      def merge(another)
        if !another.is_a?(Mimi::Core::Manifest) && !another.is_a?(Hash)
          raise ArgumentError 'Another Mimi::Core::Manifest or Hash is expected'
        end
        another_hash = another.is_a?(Hash) ? another.deep_dup : another.to_h.deep_dup
        new_manifest_hash = @manifest.deep_merge(another_hash)
        new_manifest_hash = manifest_hash_canonical(new_manifest_hash)
        self.class.validate_manifest_hash(new_manifest_hash)
        @manifest = new_manifest_hash
      end

      # Accepts the values, performs the validation and applies the manifest,
      # responding with a Hash of parameters and processed values.
      #
      # Performs the type coercion of values to the specified configurable parameter type.
      #
      #   * type: :string, value: anything => `String`
      #   * type: :integer, value: `1` or `'1'` => `1`
      #   * type: :decimal, value: `1`, `1.0 (BigDecimal)`, `'1'` or `'1.0'` => `1.0 (BigDecimal)`
      #   * type: :boolean, value: `true` or `'true'` => `true`
      #   * type: :json, value: `{ 'id' => 123 }` or `'{"id":123}'` => `{ 'id' => 123 }`
      #   * type: `['a', 'b', 'c']` , value: `'a'` => `'a'`
      #
      # Example:
      #
      # ```ruby
      # manifest = Mimi::Core::Manifest.new(
      #   var1: {},
      #   var2: :integer,
      #   var3: :decimal,
      #   var4: :boolean,
      #   var5: :json,
      #   var6: ['a', 'b', 'c']
      # )
      #
      # manifest.apply(
      #   var1: 'var1.value',
      #   var2: '2',
      #   var3: '3',
      #   var4: 'false',
      #   var5: '[{"name":"value"}]',
      #   var6: 'c'
      # )
      # # =>
      # # {
      # #   var1: 'var1.value', var2: 2, var3: 3.0, var4: false,
      # #   var5: [{ 'name' => 'value '}], var6: 'c'
      # # }
      # ```
      #
      # If `:default` is specified for the parameter and the value is not provided,
      # the default value is returned as-is, bypassing validation and type coercion.
      #
      # ```ruby
      # manifest = Mimi::Core::Manifest.new(var1: { default: nil })
      # manifest.apply({}) # => { var1: nil }
      # ```
      #
      # Values for parameters not defined in the manifest are ignored:
      #
      # ```ruby
      # manifest = Mimi::Core::Manifest.new(var1: {})
      # manifest.apply(var1: '123', var2: '456') # => { var1: '123' }
      # ```
      #
      # Configurable parameters defined as `:const` cannot be changed by provided values:
      #
      # ```ruby
      # manifest = Mimi::Core::Manifest.new(var1: { default: 1, const: true })
      # manifest.apply(var1: 2) # => { var1: 1 }
      # ```
      #
      # If a configurable parameter defined as *required* in the manifest (has no `:default`)
      # and the provided values have no corresponding key, an ArgumentError is raised:
      #
      # ```ruby
      # manifest = Mimi::Core::Manifest.new(var1: {})
      # manifest.apply({}) # => ArgumentError "Required value for 'var1' is missing"
      # ```
      #
      # If a value provided for the configurable parameter is incompatible (different type,
      # wrong format etc), an ArgumentError is raised:
      #
      # ```ruby
      # manifest = Mimi::Core::Manifest.new(var1: { type: :integer })
      # manifest.apply(var1: 'abc') # => ArgumentError "Invalid value provided for 'var1'"
      # ```
      #
      # During validation of provided values, all violations are detected and reported in
      # a single ArgumentError:
      #
      # ```ruby
      # manifest = Mimi::Core::Manifest.new(var1: { type: :integer }, var2: {})
      # manifest.apply(var1: 'abc') # =>
      # # ArgumentError "Invalid value provided for 'var1'. Required value for 'var2' is missing."
      # ```
      #
      # @param values [Hash]
      # @return [Hash<Symbol,Object>] where key is the parameter name, value is the parameter value
      #
      # @raise [ArgumentError] on validation errors, missing values etc
      #
      def apply(values)
        raise ArgumentError, 'Hash is expected as values' unless values.is_a?(Hash)
        validate_values(values)
        process_values(values)
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

      private

      # Sets the missing default properties in the properties Hash, converts values
      # to canonical form.
      #
      # @param properties [Hash] set of properties of a configurable parameter
      # @return [Hash] same Hash with all the missing properties set
      #
      def properties_canonical(properties)
        properties = {
          desc:   '',
          type:   :string,
          hidden: false,
          const:  false
        }.merge(properties)
        properties[:desc] = properties[:desc].to_s
        if properties[:type].is_a?(Array)
          properties[:type] = properties[:type].map { |v| v.to_s }
        elsif properties[:type].is_a?(String)
          properties[:type] = properties[:type].to_sym
        end
        properties[:hidden] = !!properties[:hidden]
        properties[:const] = !!properties[:const]
        properties
      end

      # Converts a valid manifest Hash to a canonical form, with all defaults set
      # and property values coerced:
      #
      # Example
      #
      # ```ruby
      # manifest_hash_canonical(
      #   var1: {},
      #   var2: {
      #     type: 'string',
      #     hidden: nil,
      #     default: 1,
      #     const: false
      #   }
      # )
      # # =>
      # # {
      # #   var1: { desc: '', type: :string, hidden: false, const: false },
      # #   var2: { desc: '', type: :string, default: 1, hidden: false, const: false }
      # # }
      #
      # ```
      #
      # @param manifest_hash [Hash]
      # @return [Hash]
      #
      def manifest_hash_canonical(manifest_hash)
        manifest_hash.map do |name, props|
          [name, properties_canonical(props)]
        end.to_h
      end

      # Validates provided values
      #
      # @param values [Hash]
      # @raise [ArgumentError] if any of the values are invalid or missing
      #
      def validate_values(values)
        missing_values = @manifest.keys.select do |key|
          if @manifest[key].keys.include?(:default)
            false # not required value
          else
            values[key].nil? # value required and missing
          end
        end
        invalid_values = @manifest.keys.reject do |key|
          type = @manifest[key][:type]
          value = values[key]
          case type
          when :string
            true # anything is valid
          when :integer
            value.is_a?(Integer) || (value.is_a?(String) && value =~ /^\d+$/)
          when :decimal
            value.is_a?(Integer) || value.is_a?(BigDecimal) ||
              (value.is_a?(String) && value =~ /^\d+(\.\d+)?$/)
          when :boolean
            value.is_a?(TrueClass) || value.is_a?(FalseClass) ||
              (value.is_a?(String) && value =~ /^(true|false)$/)
          when :json
            validate_value_json(value)
          when Array
            type.include?(value)
          else
            raise "Unexpected type '#{type}' for '#{key}'"
          end
        end
        messages =
          missing_values.map do |key|
            "Required value for '#{key}' is missing."
          end + invalid_values.map do |key|
            "Invalid value provided for '#{key}'."
          end
        raise ArgumentError, messages.join(' ') unless messages.empty?
      end

      # Validates a single JSON value
      #
      # * must be a String
      # * must be a valid JSON
      #
      # @param value [String]
      # @return [true,false]
      #
      def validate_value_json(value)
        return false unless value.is_a?(String)
        JSON.parse(value)
        true
      rescue JSON::ParserError
        false
      end

      # Processes the given set of values and returns a Hash of configurable parameter
      # values.
      #
      # @param values [Hash]
      # @return [Hash]
      #
      def process_values(values)
        @manifest.map do |name, props|
          [name, process_single_value(values[name], props)]
        end.to_h
      end

      # Processes a single value with a given set of configurable parameter properties
      #
      # @param value [Object,nil] nil indicates the value is not provided (default should be used)
      # @param properties [Hash]
      # @return [Object]
      #
      def process_single_value(value, properties)
        if properties[:const] || value.nil?
          return properties[:default].is_a?(Proc) ? properties[:default].call : properties[:default]
        end
        case properties[:type]
        when :string
          value.to_s
        when :integer
          value.to_i
        when :decimal
          BigDecimal(value)
        when :boolean
          value.is_a?(TrueClass) || value == 'true'
        when :json
          JSON.parse(value)
        when Array
          value
        else
          raise "Unexpected type '#{type}' for '#{key}'"
        end
      end
    end # class Manifest
  end # module Core
end # module Mimi
