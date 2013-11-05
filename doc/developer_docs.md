Hammer Development Docs
=======================

Hammer is a generic clamp-based CLI framework. It uses existing clamp features and adds some extra utilities.
We recommend to get familiar with the [Clamp documentation](https://github.com/mdub/clamp/#quick-start)
before creating some hammer specific plugins.


Writing your own Hammer plugin
------------------------------

In this tutorial we will create a simple hello world plugin.

Hammer plugins are nothing but gems. Details on how to build a gem can be found for example at [rubygems.org](http://guides.rubygems.org/make-your-own-gem/).
In the first part of this tutorial we will briefly guide you through the process of creating a very simple gem. First of all you will need rubygems package installed on your system.

Create the basic gem structure in a project subdirectory of your choice:
```
$ cd ./my_first_hammer_plugin/
$ touch Gemfile
$ touch hammer_cli_hello.gemspec
$ mkdir -p lib/hammer_cli_hello
$ touch lib/hammer_cli_hello.rb
$ touch lib/hammer_cli_hello/version.rb
```

Example `Gemfile`:
```ruby
source "https://rubygems.org"

gemspec
```

Example `hammer_cli_hello.gemspec` file:
```ruby
$:.unshift File.expand_path("../lib", __FILE__)
require "hammer_cli_hello/version"

Gem::Specification.new do |s|

  s.name = "hammer_cli_hello"
  s.authors = ["Me"]
  s.version = HammerCLIHello.version.dup
  s.platform = Gem::Platform::RUBY
  s.summary = %q{Hello world commands for Hammer}

  s.files = Dir['lib/**/*.rb']
  s.require_paths = ["lib"]

  s.add_dependency 'hammer_cli', '>= 0.0.6'
end
```
More details about the gemspec structure is again at [rubygems.org](http://guides.rubygems.org/specification-reference/).

We'll have to specify the plugins version in `lib/hammer_cli_hello/version.rb`:
```ruby
module HammerCLIHello
  def self.version
    @version ||= Gem::Version.new '0.0.1'
  end
end
```

This should be enough for creating a minimalist gem. Let's build and install it.
```
$ gem build ./hammer_cli_hello.gemspec
$ gem install hammer_cli_hello-0.0.1.gem
```

Update the hammer config to enable your plugin.
```yaml
:modules:
  - hammer_cli_hello
# - hammer_cli_foreman
# - hammer_cli_katello_bridge
```


Verify the installation by running:
```
$ hammer -v > /dev/null
```

You should see a message saying that your module was loaded (second line in the sample output).
```
[ INFO 2013-10-16 11:19:06 Init] Configuration from the file /etc/foreman/cli_config.yml has been loaded
[ INFO 2013-10-16 11:19:06 Init] Extension module hammer_cli_hello loaded
[ INFO 2013-10-16 11:19:06 HammerCLI::MainCommand] Called with options: {"verbose"=>true}
```

Done. Your first hammer plugin is installed. Unfortunatelly it does not contain any commands yet. So let's start adding some to finally enjoy real results.

Optionally you can add a Rakefile and build and install the gem with `rake install`
```ruby
# ./Rakefile
require 'bundler/gem_tasks'
```


Create your first command
-------------------------

We will create a simple command called `hello` that will print a sentence "Hello World!" to stdout.

### Declare the command

```
touch ./lib/hammer_cli_hello/hello_world.rb
```

```ruby
# ./lib/hammer_cli_hello/hello_world.rb
require 'hammer_cli'

# it's a good practise to nest commands into modules
module HammerCLIHello

  # hammer commands must be descendants of AbstractCommand
  class HelloCommand < HammerCLI::AbstractCommand

    # execute is the heart of the command
    def execute
      # we use print_message instead of simple puts
      # the reason will be described later in the part called Output
      print_message "Hello World!"
    end
  end

  # now plug your command into the hammer's main command
  HammerCLI::MainCommand.subcommand
    'hello',                  # command's name
    "Say Hello World!",       # description
    HammerCLIHello::HelloCommand  # the class
end
```

The last bit is to require the file with your command in `hammer_cli_hello.rb`.
Hammer actually loads this file and this is how the commands from plugins get loaded
into hammer.
```ruby
# ./lib/hammer_cli_hello.rb
require 'hammer_cli_hello/hello_world'
```

Rebuild and reinstall your plugin and see the results of `hammer -h`
```
gem build ./hammer_cli_hello.gemspec && gem install hammer_cli_hello-0.0.1.gem
```


```
$ hammer -h
Usage:
    hammer [OPTIONS] SUBCOMMAND [ARG] ...

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    shell                         Interactive Shell
    hello                         Say Hello World!

Options:
    -v, --verbose                 be verbose
    -c, --config CFG_FILE         path to custom config file
    -u, --username USERNAME       username to access the remote system
    -p, --password PASSWORD       password to access the remote system
    --version                     show version
    --show-ids                    Show ids of associated resources
    --csv                         Output as CSV (same as --adapter=csv)
    --output ADAPTER              Set output format. One of [csv, table, base, silent]
    --csv-separator SEPARATOR     Character to separate the values
    -P, --ask-pass                Ask for password
    --autocomplete LINE           Get list of possible endings
    -h, --help                    print help
```

Now try running the command.

```
$ hammer hello
Hello World!
Error: exit code must be integer
```

What's wrong here? Hammer requires integer exit codes as return values from the method `execute`.
It's usually just `HammerCLI::EX_OK`. Add it as the very last line of `execute`, rebuild and the
command should run fine.

See [exit_codes.rb](https://github.com/theforeman/hammer-cli/blob/master/lib/hammer_cli/exit_codes.rb)
for the full list of available exit codes.


### Declaring options
Our new command has only one option so far. It's `-h` which is built in for every command by default.
Option declaration is the same as in clamp so please read it's
[documentation](https://github.com/mdub/clamp/#declaring-options)
on that topic.

Example option usage could go like this:
```ruby
class HelloCommand < HammerCLI::AbstractCommand

  option '--name', "NAME", "Name of the person you want to greet"

  def execute
    print_message "Hello %s!" % (name || "World")
    HammerCLI::EX_OK
  end
end
```

```
$ hammer hello -h
Usage:
    hammer hello [OPTIONS]

Options:
    --name NAME                   Name of the person you want to greet
    -h, --help                    print help
```

```
$ hammer hello --name 'Foreman'
Hello Foreman!
```


### Option validation
Hammer provides extended functionality for validating options.

#### DSL
First of all there is a dsl for validating combinations of options:
```ruby
validate_options do
  all(:name, :surname).required  # requires all the options
  option(:age).required          # requires a single option,
                                 # equivalent of :required => true in option declaration
  any(:email, :phone).required   # requires at least one of the options

  # Tt is possible to create more complicated constructs.
  # This example requires either the full address or nothing
  if any(:street, :city, :zip).exist?
    all(:street, :city, :zip).required
  end

  # Here you can reject all address related option when --no-address is passed
  if option(:no_address).exist?
    all(:street, :city, :zip).rejected
  end
end

```

#### Option normalizers
Another option-related feature is a set of normalizers for specific option types. They validate and preprocess
option values. Each normalizer has a description of the format it accepts. This description is printed
in commands' help.

##### _List_

Parses comma separated strings to a list of values.

```ruby
option "--users", "USER_NAMES", "List of user names",
  :format => HammerCLI::Options::Normalizers::List.new
```
`--users='J.R.,Gary,Bobby'` -> `['J.R.', 'Gary', 'Bobby']`

##### _File_

Loads contents of a file and returns it as a value of the option.

```ruby
option "--poem", "PATH_TO_POEM", "File containing the text of your poem",
  :format => HammerCLI::Options::Normalizers::File.new
```
`--poem=~/verlaine/les_poetes_maudits.txt` -> content of the file

##### _Bool_

Case insensitive true/false values. Translates _yes,y,true,t,1_ to `true` and _no,n,false,f,0_ to `false`.

```ruby
option "--start", "START", "Start the action",
  :format => HammerCLI::Options::Normalizers::Bool.new
```
`--start=yes` -> `true`

##### _KeyValueList_

Parses a comma separated list of key=value pairs. Can be used for naming attributes with vague structure.

```ruby
option "--attributes", "ATTRIBUTES", "Values of various attributes",
  :format => HammerCLI::Options::Normalizers::KeyValueList.new
```
`--attributes="material=unoptanium,thickness=3"` -> `{'material' => 'unoptanium', 'thickness' => '3'}`

### Adding subcommands
Commands in the cli can be structured into a tree of parent commands (nodes) and subcommands (leaves).
Neither the number of subcommands nor the nesting is limited. Please note that no parent command
can perform any action and therefore it's useless to define `execute` method for them. This limit
comes from Clamp's implementation of the command hierarchy.

We've already used command nesting for plugging the `HelloCommand` command into the main command.
But let's create a new command `say` and show how to connect it with others to be more demonstrative.

```ruby
module HammerCLIHello

  # a new parent command 'say'
  class SayCommand < HammerCLI::AbstractCommand

    # subcommand 'hello' remains the same
    class HelloCommand < HammerCLI::AbstractCommand

      option '--name', "NAME", "Name of the person you want to greet"

      def execute
        print_message "Hello %s!" % (name || "World")
        HammerCLI::EX_OK
      end
    end

    # plug the original command into 'say'
    subcommand 'hello', "Say Hello World!", HammerCLIHello::SayCommand::HelloCommand
  end

  # plug the 'say' command into the main command
  HammerCLI::MainCommand.subcommand 'say', "Say something", HammerCLIHello::SayCommand
end
```

The result will be:
```
$ hammer say hello
Hello World!
```

This is very typical usage of subcommands. When you create more of them it may feel a bit
duplicit to always define the subcommand structure at the end of the class definition.
Hammer provides utility methods for subcommand autoloading. This is handy especially
when you have growing number of subcommands. See how it works in the following example:

```ruby
module HammerCLIHello

  class SayCommand < HammerCLI::AbstractCommand

    class HelloCommand < HammerCLI::AbstractCommand
      command_name 'hello'      # name and description moves to the command's class
      desc 'Say Hello World!'
      # ...
    end

    class HiCommand < HammerCLI::AbstractCommand
      command_name 'hi'
      desc 'Say Hi World!'
      # ...
    end

    class ByeCommand < HammerCLI::AbstractCommand
      command_name 'bye'
      desc 'Say Bye World!'
      # ...
    end

    autoload_subcommands
  end

  HammerCLI::MainCommand.subcommand 'say', "Say something", HammerCLIHello::SayCommand
end
```

```
$ hammer say
Usage:
    hammer say [OPTIONS] SUBCOMMAND [ARG] ...

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    hi                            Say Hi World!
    hello                         Say Hello World!
    bye                           Say Bye World!

Options:
    -h, --help                    print help
```


### Conflicting subcommands
It can happen that two different plugins define subcommands with the same name by accident.
In such situations `subcommand` will throw an exception. If this is intentional and you
want to redefine the existing command, use `subcommand!`.
This method does not throw exceptions, replaces the original subcommand, and leaves
a message in a log for debugging purposes.


### Printing some output
We've mentioned above that it's not recommended practice to print output
directly with `puts` in Hammer. The reason is we separate definition
of the output from its interpretation. Hammer uses so called _output adapters_
that can modify the output format.

Hammer comes with four basic output adapters:
  * __base__   - simple output, structured records
  * __table__  - records printed in tables, ideal for printing lists of records
  * __csv__    - comma separated output, ideal for scripting and grepping
  * __silent__ - no output, used for testing

The detailed documentation on creating adapters is coming soon.

#### Printing messages
Very simple, just call
```ruby
print_message(msg)
```

#### Printing hash records
Typical usage of a cli is interaction with some api. In many cases it's listing
some records returned by the api.

Hammer comes with support for selecting and formatting of hash record fields.
You first create so called _output definition_ that you apply on your data. The result
is a collection of fields each having its type. The collection is then passed to some
_output adapter_ which handles the actuall formatting and printing.

Hammer provides a DSL for defining the output. Next rather complex example will
explain how to use it in action.

Imagine there's an API of some service that returns list of users:
```ruby
[{
  :id => 1,
  :email => 'tom@email.com',
  :phone => '123456111',
  :first_name => 'Tom',
  :last_name => 'Sawyer',
  :roles => ['Admin', 'Editor'],
  :timestamps => {
      :created => '2012-12-18T15:24:42Z',
      :updated => '2012-12-18T15:24:42Z'
  }
},{
  :id => 2,
  :email => 'huckleberry@email.com',
  :phone => '123456222',
  :first_name => 'Huckleberry',
  :last_name => 'Finn',
  :roles => ['Admin'],
  :timestamps => {
      :created => '2012-12-18T15:25:00Z',
      :updated => '2012-12-20T14:00:15Z'
  }
}]
```

We can create an output definition that selects and formats some of the fields:
```ruby
dsl = HammerCLI::Output::Dsl.new
dsl.build do

  # Simple field with a label. The first parameter is key in the printed hash.
  field :id, 'ID'

  # Fields can have types. The type determines how the field is printed.
  # All available types are listed below.
  # Here we want the roles to act as list.
  field :roles, 'System Roles', Fields::List

  # Label is used for grouping fields.
  label 'Contacts' do
    field :email, 'Email'
    field :phone, 'Phone No.'
  end

  # From is used for accessing nested fields.
  from :timestamps do
    # See how date gets formatted in the output
    field :created, 'Created At', Fields::Date
  end
end

definition = HammerCLI::Output::Definition.new
definition.append(dsl.fields)

print_records(definition, data)

```

Using the base adapter the output will look like:
```
ID:            1
System Roles:  Admin, Editor
Name:          Tom Sawyer
Contacts:
  Email:       tom@email.com
  Phone No.:   123456111
Created At:    2012/12/18 15:24:42

ID:            2
System Roles:  Admin
Name:          Huckleberry Finn
Contacts:
  Email:       huckleberry@email.com
  Phone No.:   123456222
Created At:    2012/12/18 15:25:00
```

All Hammer field types are:
 * __Date__
 * __Id__ - Used to mark ID values, current print adapters have support for turning id printing on/off.
 See hammer's parameter `--show-ids`.
 * __List__
 * __KeyValue__ - Formats hashes containing `:name` and `:value`
 * __Collection__ - Enables to render subcollections. Takes a block with another output definition.

The default adapter for every command is Base adapter. It is possible to override
the default one by redefining command's method `adapter`.

```ruby
def adapter
  # return :base, :table, :csv or name of your own adapter here
  :table
end
```


Other useful command features
-----------------------------

#### Logging
Hammer provides integrated [logger](https://github.com/TwP/logging)
with broad setting options (use hammer's config file):

```yaml
:log_dir: '<path>'    # - directory where the logs are stored.
                      #   The default is /var/log/foreman/ and the log file is named hammer.log
:log_level: '<level>' # - logging level. One of debug, info, warning, error, fatal
:log_owner: '<owner>' # - logfile owner
:log_group: '<group>' # - logfile group
:log_size: 1048576  # - size in bytes, when exceeded the log rotates. Default is 1MB
:watch_plain: false # - turn on/off syntax highlighting of data being logged in debug mode
```

Example usage in commands:
```ruby
# Get a logger instance
logger('Logger name')

# It uses a command class name as the logger's name by default
logger

# Log a message at corresponding log level
logger.debug("...")
logger.error("...")
logger.info("...")
logger.fatal("...")
logger.warn("...")

# Writes an awesome print dump of a value to the log
logger.watch('Some label', value)
```

#### Exception handling
Exception handling in Hammer is centralized by
[ExceptionHandler](https://github.com/theforeman/hammer-cli/blob/master/lib/hammer_cli/exception_handler.rb).
Each plugin, module or even a command can have a separate exception handler. The exception handler class
is looked up in the module structure from a command to the top level.

Define method `self.exception_handler_class` in your plugin's module to use a custom exception handler:
```ruby
# ./lib/hammer_cli_hello.rb

module HammerCLIHello

  def self.exception_handler_class
    HammerCLIHello::CustomExceptionHandler
  end
end

require 'hammer_cli_hello/hello_world'
```

Centralized exception handling implies that you should raise exceptions on error states in your command
rather than handle it and return error codes. This approach guarrantees that error messages are logged and
printed consistently and correct exit codes are returned.


#### Configuration
Values form config files are accesible via class `HammerCLI::Settings`.
It's method `get` returns either the value or nil when it's not found.

Config values belonging to a specific plugin must be nested under
the plugin's name in config files.

```yaml
#cli_config.yml
:log_dir: /var/log/hammer/
:hello_world:
    :name:  John
```

```ruby
HammerCLI::Settings.get(:log_dir)             # get a value
HammerCLI::Settings.get(:hello_world, :name)  # get a nested value
```

There's more ways where to place your config file for hammer.
Read more in [the settings howto](https://github.com/theforeman/hammer-cli#configuration).


Creating commands for RESTful API with ApiPie
---------------------------------------------

CLIs binded to a rest api do simillar things for most of the resources. Typically it's
CRUD actions that appear for nearly every resource. Actions differ with parameters
accross resources but the operations remain the same.

Hammer is optimised for usage with [ApiPie](https://github.com/Pajk/apipie-rails)
and generated api bindings and tries to reduce the effort neccessary for a command creation.


### ApiPie and bindings

[ApiPie](https://github.com/Pajk/apipie-rails) is a documentation library for RESTful APIs.
Unlike traditional tools ApiPie uses DSL for api description. This brings many advantages. See its
documentation for details.

Foreman comes with [ruby bindings](https://github.com/theforeman/foreman_api) automatically generated
from the information provided by ApiPie. Every resource (eg. Architecture, User) has it's own
class with methods for each available action (eg. create, show, index, destroy).
Apart from that it contains also full api documentation with parameters for the actions.
This enables to reuse the documentation on client side for automatic option definition
and reduce the amount of custom code per CLI action.


### ApiPie commands in Hammer

Hammer identifies two basic types of ApiPie commands:

-  __ReadCommand__
  - should be used for actions that print records
  - retrieves the data and prints them in given format (uses output definition)
  - typical actions in rails terminology: _index, show_

- __WriteCommand__
  - should used for actions that modify records
  - sends modifying request and prints the result
  - typical actions in rails terminology: _create, update, destroy_

Both command classes are single resource related and expect the resource and an action to be defined.
There's a simple DSL for that:

```ruby
class ListCommand < HammerCLI::Apipie::ReadCommand
  # define resource and the action together
  resource ForemanApi::Resources::Architecture, :index
end

# or

class ListCommand2 < HammerCLI::Apipie::ReadCommand
  # define them separately
  resource ForemanApi::Resources::Architecture
  action :index
end
```

#### Options definition

When the resource-action pair is defined we can take the advantage of automatic option definition.
There's a class method `apipie_options` for this purpose.

```ruby
class ListCommand < HammerCLI::Apipie::ReadCommand
  resource ForemanApi::Resources::Architecture, :index

  apipie_options
end
```

If we plug the command into an existing command tree and check the help we will see there
are four parameters defined from the ApiPie docs. Compare the result with
[online api documentation](http://www.theforeman.org/api/apidoc/architectures/index.html).
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
doesn't suit your needs for any reason, you can always skip and redefine them by hand.
See following example.
```ruby
class ListCommand < HammerCLI::Apipie::ReadCommand
  resource ForemanApi::Resources::Architecture, :index

  apipie_options :without => [:search, :order]
  option '--search', 'QUERY', "search query"
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

Automatic options reflect:
- parameter names and descriptions
- required parameters
- parameter types - the only supported type is array, which is translated to option normalizer `List`

#### Write commands

Write commands are expected to print result of the api action. There are
two class methods for setting success and failure messages. Messages are
printed according to the http status code the api returned.

```ruby
success_message "The user has been created"
failure_message "Could not create the user"
```


#### Example 1: Create an architecture

```ruby
class CreateCommand < HammerCLI::Apipie::WriteCommand
  command_name "create"
  resource ForemanApi::Resources::Architecture, :create

  success_message "Architecture created"
  failure_message "Could not create the architecture"

  apipie_options
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
class InfoCommand < HammerCLI::Apipie::ReadCommand
  command_name "info"
  resource ForemanApi::Resources::Architecture, :show

  # It's a good practice to reuse output definition from list commands
  # and add more details. It helps avoiding duplicities.
  output ListCommand.output_definition do
    from "architecture" do
      field :operatingsystem_ids, "OS ids", Fields::List
      field :created_at, "Created at", Fields::Date
      field :updated_at, "Updated at", Fields::Date
    end
  end

  apipie_options
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

When you define more command like we've shown above you find yourself repeating
`resource ...` in every one of them. As the commands are usually grouped by
the resource it is handy to extract the resource definition one level up to
the encapsulating command.

```ruby
 class Architecture < HammerCLI::Apipie::Command

    resource ForemanApi::Resources::Architecture

    class ListCommand < HammerCLI::Apipie::ReadCommand
      action :index
      # ...
    end


    class InfoCommand < HammerCLI::Apipie::ReadCommand
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
any parent of which resource implements method `add_tag`. Please note that this example
is fictitious. There's no tags in Foreman's architectures and users.
```ruby
module Tags
  class AddTag < HammerCLI::Apipie::WriteCommand
    option '--id', 'ID', 'ID of the resource'
    option '--tag', 'TAG', 'Name of the tag to add'
    action :add_tag
    command_name 'add_tag'
  end
end

class Architecture < HammerCLI::Apipie::Command
  resource ForemanApi::Resources::Architecture
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
$ hammer architecture add_tag -h
Usage:
    hammer architecture add_tag [OPTIONS]

Options:
    --id ID                       ID of the resource
    --tag TAG                     Name of the tag to add
    -h, --help                    print help
```

```
$ hammer user add_tag -h
Usage:
    hammer user add_tag [OPTIONS]

Options:
    --id ID                       ID of the resource
    --tag TAG                     Name of the tag to add
    -h, --help                    print help
```

