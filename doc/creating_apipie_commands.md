Creating commands for RESTful API with ApiPie
---------------------------------------------

CLIs bound to a REST API do simillar things for most of the resources. Typically there are
CRUD actions that appear for nearly every resource. Actions differ with parameters
accross resources but the operations remain the same.

Hammer is optimised for usage with [ApiPie](https://github.com/Pajk/apipie-rails)
and generated API bindings and tries to reduce the effort neccessary for a command creation.


### ApiPie and bindings

[ApiPie](https://github.com/Pajk/apipie-rails) is a documentation library for RESTful APIs.
Unlike traditional tools ApiPie uses DSL for API descriptions. This brings many advantages. See its
documentation for details.

Foreman comes with [ruby bindings](https://github.com/theforeman/foreman_api) automatically generated
from the information provided by ApiPie. Every resource (eg. Architecture, User) has it's own
class with methods for each available action (e.g. create, show, index, destroy).
Apart from that it contains also full API documentation with parameters for the actions.
This allows to reuse the documentation on the client side for automatic option definition
and to reduce the amount of custom code per CLI action.


### ApiPie commands in Hammer

Hammer provides `HammerCLI::Apipie::Command` base class for apipie actions.
The command class is single resource related and expect the resource and an action to be defined.

There's a simple DSL for that:

```ruby
class ListCommand < HammerCLI::Apipie::Command
  # define resource and the action together
  resource :architectures, :index
end

# or

class ListCommand2 < HammerCLI::Apipie::Command
  # define them separately
  resource :architectures
  action :index
end
```

#### Options definition

When the resource-action pair is defined we can take advantage of automatic option definition.
There's an [option builder](https://github.com/theforeman/hammer-cli/blob/master/lib/hammer_cli/apipie/option_builder.rb)
for apipie parameters pre-set in the apipie command's base class.
You can read details about the option builder principles [here](option_builders.md#option-builders).


```ruby
class ListCommand < HammerCLI::Apipie::Command
  resource :architectures, :index

  build_options
end
```

If we plug the command into an existing command tree and check the help we will see there
are four parameters defined from the ApiPie docs. Compare the result with
[online API documentation](http://www.theforeman.org/api/apidoc/architectures/index.html).
```
$ hammer architecture list -h
Usage:
    hammer architecture list [OPTIONS]

Options:
    --search SEARCH               filter results
    --order ORDER                 sort results
    --page PAGE                   paginate results
    --per-page PER_PAGE           number of entries per request
    -h, --help                    print help
```

It is possible to combine apipie options with custom ones. If the generated options
don't suit your needs for any reason, you can always redefine them by hand or just skip them.

See following example.
```ruby
class ListCommand < HammerCLI::Apipie::Command
  resource :architectures, :index

  # first created option takes precedence
  option '--search', 'QUERY', "search query"

  # use option :without to define what options should be skipped
  build_options :without => [:order]
end
```

```
hammer architecture list -h
Usage:
    hammer architecture list [OPTIONS]

Options:
    --page PAGE                   paginate results
    --per-page PER_PAGE           number of entries per request
    --search QUERY                search query
    -h, --help                    print help
```
Note that the `--search` description has changed and `--order` disappeared.

Automaticaly generated options reflect:
- parameter names and descriptions
- required parameters
- parameter types - the only supported type is array, which is translated to option normalizer `List`

#### Status messages

Some commands are expected to print result of the API action. There are
two class methods for setting success and failure messages. Messages are
printed according to the HTTP status code the API returned.

```ruby
success_message "The user has been created"
failure_message "Could not create the user"
```


#### Example 1: Create an architecture

```ruby
class CreateCommand < HammerCLI::Apipie::Command
  command_name "create"
  resource :architectures, :create

  success_message "Architecture created"
  failure_message "Could not create the architecture"

  build_options
end
```

```
$ hammer architecture create -h
Usage:
    hammer architecture create [OPTIONS]

Options:
    --name NAME
    --operatingsystem-ids OPERATINGSYSTEM_IDS Operatingsystem ID’s
                                  Comma separated list of values.
    -h, --help                    print help
```

```
$ hammer architecture create
ERROR: option '--name' is required

See: 'hammer architecture create --help'
```

```
$ hammer architecture create --name test --operatingsystem-ids=1,2
Architecture created
```

```
$ hammer architecture create --name test
Could not create the architecture:
  Name has already been taken
```


#### Example 2: Show an architecture

```ruby
class InfoCommand < HammerCLI::Apipie::Command
  command_name "info"
  resource :architectures, :show

  # It's a good practice to reuse output definition from list commands
  # and add more details. This helps avoiding duplicities.
  output ListCommand.output_definition do
    from "architecture" do
      field :operatingsystem_ids, "OS ids", Fields::List
      field :created_at, "Created at", Fields::Date
      field :updated_at, "Updated at", Fields::Date
    end
  end

  build_options
end
```

```
$ hammer architecture info -h
Usage:
    hammer architecture info [OPTIONS]

Options:
    --id ID
    -h, --help                    print help
```

```
$ hammer architecture info --id 1
Id:          1
Name:        x86_64
OS ids:      1, 3
Created at:  2013/06/08 18:53:56
Updated at:  2013/06/08 19:17:43
```


#### Tips

When you define more commands like we've shown above you find yourself repeating
`resource ...` in every one of them. As the commands are usually grouped by
the resource it is handy to extract the resource definition one level up to
the encapsulating command.

```ruby
 class Architecture < HammerCLI::Apipie::Command

    resource :architectures

    class ListCommand < HammerCLI::Apipie::Command
      action :index
      # ...
    end


    class InfoCommand < HammerCLI::Apipie::Command
      action :show
      # ...
    end

    # ...
  end
```

ApiPie resources are being looked up in the encapsulating classes and modules
when the definition is missing in the command class. If they are not found even there
the resource of the parent command is used at runtime. This is useful for context-aware
shared commands.

The following example shows a common subcommand that can be attached to
any parent which has a resource implementing the method `add_tag`. Please note that this example
is fictitious. There are no tags in Foreman's architectures and users.
```ruby
module Tags
  class AddTag < HammerCLI::Apipie::WriteCommand
    option '--id', 'ID', 'ID of the resource'
    option '--tag', 'TAG', 'Name of the tag to add'
    action :add_tag
    command_name 'add-tag'
  end
end

class Architecture < HammerCLI::Apipie::Command
  resource :architectures
  # ...
  include Tags
  autoload_subcommands
end

class User < HammerCLI::Apipie::Command
  resource ForemanApi::Resources::User
  # ...
  include Tags
  autoload_subcommands
end
```

```
$ hammer architecture add-tag -h
Usage:
    hammer architecture add-tag [OPTIONS]

Options:
    --id ID                       ID of the resource
    --tag TAG                     Name of the tag to add
    -h, --help                    print help
```

```
$ hammer user add-tag -h
Usage:
    hammer user add-tag [OPTIONS]

Options:
    --id ID                       ID of the resource
    --tag TAG                     Name of the tag to add
    -h, --help                    print help
```

