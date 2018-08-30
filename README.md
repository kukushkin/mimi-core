# mimi-core

`mimi-core` is a base for building Mimi modules.

See: 'mimi' -- microframework for microservices.

## Mimi::Core::Module

`Mimi::Core::Module` is a base for any Mimi module.

Mimi modules are pluggable components that you can include in your applications. They provide some useful functionality, e.g. database abstraction layer, logging etc.

Apart from implementing some logic and API to utilize it, any Mimi module offers a straightforward and unified way to configure it, and optionally a set of module-specific rake tasks. For example, including a `Mimi::DB` in an application makes some rake tasks available:

```
$ rake -T
...
rake db:clear                   # Clear database
rake db:config                  # Show database config
rake db:create                  # Create database
rake db:drop                    # Drop database
rake db:migrate                 # Migrate database (schema and seeds)
rake db:migrate:schema          # Migrate database (schema only)
rake db:migrate:schema:diff     # Display differences between existing DB schema and target schema
rake db:migrate:schema:dry_run  # Migrate database (schema only) (DRY RUN)
rake db:migrate:seeds           # Migrate database (seeds only)
...
```

### Creating a new module

Usage:
```ruby
# my_module.rb

require 'mimi-core'

module Mimi::MyModule
  include Mimi::Core::Module
end
```

### Loading a module

```ruby
require 'mimi-core'
require_relative 'my_module'

Mimi.use Mimi::MyModule
```

### Configuring a module

A Mimi module can define a `.configure` class method, that will be used to provide
module's configuration.


* module options
* exposed options?

### Module manifest


## Core extensions


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

