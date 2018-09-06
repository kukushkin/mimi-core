# mimi-core

Core module of the [Mimi framework](Mimi).

`mimi-core` defines the top-level Mimi namespace, provides a base for Mimi modules
and offers some core extentions.


## Mimi namespace

At the top of hierarchy of the Mimi components there is a `Mimi` module that binds all components of the
framework together. It allows Mimi modules to be used (included in the stack and configured), started
and stopped.

```ruby
require 'mimi/core'

Mimi # => Module
```

### Mimi.use(mod)

Configures the given module and appends it to the list of **used modules**.

### Mimi.start

Starts the used modules in the order of appending.

### Mimi.stop

Stops the used modules in reverse order.

### Example

```ruby
require 'mimi/db'

Mimi.use Mimi::DB, db_adapter: 'sqlite', db_database: 'tmp/dev.db'
Mimi.start

Mimi.app_root_path # => <Pathname> -- guesses current application's root
```

## Mimi::Core::Module

`Mimi::Core::Module` is a base for any Mimi module.

Mimi modules are pluggable components that you can include in your applications.
They provide some useful functionality, e.g. database abstraction layer, logging etc.

Any Mimi module provides a standard list of methods to interact with it:

```
.configure(opts)
.start
.stop
```

A Mimi module is typically packaged as a gem and it can declare a `module_root_path`.
Under this path the module may export some files, related to the module's offered functionality.
For example `Mimi::DB` exposes some rake tasks to perform database clearing, migrations etc.


### Creating a new module

A Mimi component module can be created by including `Mimi::Core::Module` in a module or class
of yours:

```ruby
# my_module.rb

require 'mimi-core'

module MyModule
  include Mimi::Core::Module
end

Mimi.use MyModule, param: 1 # invokes MyModule.configure(param: 1)
Mimi.start                  # invokes MyModule.start
```


### Configuring a module

A Mimi module implements a `.manifest`, `.configure` and `.options` class methods.

The `.configure` class method accepts a Hash of configurable parameter values and sets the options Hash
available via `.options` class method. Which parameters can be set and whether there are any default
values for the parameters is defined by the module *manifest*.

```ruby
Mimi.configure(param: 1)
Mimi.options[:param] # => 1
```

### Module manifest

The original `.configure` implementation in `Mimi::Core::Module` takes into consideration the
module *manifest*.

Module manifest is a set of formal definitions of configurable parameters.

The manifest declares which configurable parameters are accepted by the module,
which types of values are accepted, which are default values and so on.

When designing your own module, you should redefine `.manifest` method to contain
your module's actual manifest. The `.manifest` class method should return a Hash representation of the module manifest,
where keys define the configurable parameter names, and values are Hash-es with the configurable parameter
properties:


```ruby
# my_module.rb

require 'mimi-core'

module MyModule
  include Mimi::Core::Module

  def self.manifest
    {
      param1: {} # minimal definition of a configurable parameter
    }
  end
end

Mimi.configure(param: 1)
Mimi.options[:param] # => 1
```

Recognised configurable parameter properties are:

* `:desc` -- (default: `nil`) human readable description
* `:type` -- (default: `:string`) accepted value type
* `:default` -- (default: `nil`) default value for configurable parameter
* `:const` -- (default: `false`) makes the configurable parameter constant
* `:hidden` -- (default: `false`) omits the configurable parameter from a combined manifest


Example:

```ruby
def self.manifest
  {
    param1: {
      desc: 'My configurable param1',
      type: :integer,
      default: 1
    },
  }
end
```

@see Mimi::Core::Manifest

## Useful extensions

`mimi-core` gem contains some useful extensions which are included automatically, once the gem
is *require*-d:

* Mimi::Core::InheritableProperty
* Array and Hash extensions

### Mimi::Core::InheritableProperty

Makes `.inheritable_property` method available to the class.

Example:

```ruby
class A
  include Mimi::Core::InheritableProperty

  inheritable_property :my_var
end
```
@see Mimi::Core::InheritableProperty::ClassMethods#inheritable_property


### Array and Hash extensions

`Array` extensions:

```
Array#only(*values)     # select array elements only if listed in 'values'
Array#only!(*values)    # as above, modify array in-place
Array#except(*values)   # reject array elements listed in 'values'
Array#except!(*values)  # as above, modify array in-place
```

`Hash` extensions:

```
Hash#only(*keys)        # keep only those key-value pairs of the Hash which keys are listed in 'keys'
Hash#only!(*keys)       # as above, modify Hash in-place
Hash#except(*keys)      # reject key-value pairs of the Hash which keys are listed in 'keys'
Hash#except!(*keys)     # as above, modify Hash in-place
Hash#deep_merge(other)  # deep-merges another Hash
Hash#deep_dup           # deep-duplicates a Hash, taking care of nested Hashes and Arrays
Hash#deep_symbolize_keys
Hash#deep_stringify_keys
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

