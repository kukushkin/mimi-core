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
    # * `:type` (Symbol,Array<String>) -- defines the type of the parameter and the type/format of accepted values (default: :string)
    # * `:default` (Object) -- specified default value indicates that the parameter is optional
    # * `:hidden` (true,false) -- if set to true, omits the parameter from the application's combined manifest
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
      #
      # Constructs a new Manifest from its Hash representation
      #
      # @param manifest_hash [Hash,nil]
      #
      def initialize(manifest_hash = {})
        @manifest = manifest_hash.deep_dup
      end
    end # class Manifest
  end # module Core
end # module Mimi
