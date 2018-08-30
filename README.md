# mimi-core

Core module of [Mimi framework](Mimi).


## Mimi namespace

In the top of the hierarchy of Mimi components there is a `Mimi` module that binds all components of the
framework together. It allows Mimi modules to be used (included in the stack and configured), started
and stopped.

```ruby
require 'mimi/core'

Mimi # => Module
```

### Mimi.use(mod)

Configures the given module and appends it to the list of used modules.

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
Mimi.app_root_path # => <Pathname> -- guesses current application's root
```

## Module

`Mimi::Core::Module` is a base for any Mimi module.

Mimi modules are pluggable components that you can include in your applications. They provide some useful functionality, e.g. database abstraction layer, logging etc.

Any Mimi module provides a standard list of methods to interact with it:

```
.configure(opts)
.start
.stop
```

A Mimi module is typically packaged as a gem and it has a `module_root_path`. Under this path the module
may provide some rake tasks, related to the module's offered functionality. For example `Mimi::DB`
exposes some rake tasks to perform database clearing, migrations etc.


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

A Mimi module can define a `.configure` class method, that will be used to provide
module's configuration.


* module options
* exposed options?

### Module manifest

## Mimi::Core::InheritableProperty

## Core extensions


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

