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

# it's a good practice to nest commands into modules
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
on that topic. However, unlike in Clamp, the option accessors in Hammer are created with prefix 'option_', to avoid
conflict with methods of the commands. So to access value of an `--name` option you have to call `option_name()`


Example option usage could go like this:
```ruby
class HelloCommand < HammerCLI::AbstractCommand

  option '--name', "NAME", "Name of the person you want to greet"

  def execute
    print_message "Hello %s!" % (option_name || "World")
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

#### Nil values ####
To unset some option (i.e. to set it to nil value) use preset value `NIL`:
```
$ hammer hello --name NIL
Hello World!
```

When the `NIL` value collides with a real value being used it can be redefined using
environment variable `HAMMER_NIL`:
```
$ HAMMER_NIL=NULL hammer hello --name NIL
Hello NIL!
```

Note that the normalizers are not called for a NIL values even when defined for the option.

#### Deprecated options
To mark an option as deprecated use the `:deprecated` option as follows:
```ruby
  option '--name', "NAME", "Name of the person you want to greet",
    :deprecated => _('Use --alias instead')
```
It will ensure user is warned when deprecated option is used:
```
$ hammer hello --name 'Foreman'
Warning: Option --name is deprecated. Use --alias instead
Hello Foreman!
```

In cases when you want to deprecate just one of more possible switches use the extended syntax:
```ruby
  option ['--alias','--name'], "NAME", "Name of the person you want to greet",
    :deprecated => { '--name' => _('Use --alias instead') }
```

#### Predefined options
Also Hammer offers predefined options now. Those are just options, but with
predefined functionality. To define them in your command use
`use_option :option_name` method.

Here is the list of predefined options:
  * `:fields` Expects a list with fields to show in output, see [example](creating_commands.md#printing-hash-records).


### Option family
Option family is the way to unify options which have the same meaning or purpose,
but contain some differences in their definitions (e.g. the name/switch of an option).
Mainly serves as a container for options, which purpose is to show less repetitive
output in commands' help. Option builders use it by default.

To define an option family, use the following DSL:
```ruby
  # options is a Hash with options for family/each defined option within it
  option_family(options = {}) do
    # parent is the main option. Must be single, option family can have only one parent.
    parent switches, type, description, options
    # child  is an additional option. Could be none or more than one. Aren't shown in the help output.
    child  switches, type, description, options
  end
```

You can also add additional options for automatically built ones:
```ruby
  # ...
  build_options
  # If --resource-id option comes from the API params and you want to add options
  # with searchables such as --resource-name, --resource-label
  option_family(associate: 'resource') do
    child '--resource-name', 'RESOURCE', _('Resource desc'), attribute_name: :option_resource_name
    child '--resource-label', 'RESOURCE', _('Resource desc'), attribute_name: :option_resource_label
  end
  # $ hammer command --help:
  # ...
  #  Options:
  #    --resource[-id|-name|-label]               Resource desc
  # ...
```

##### Example

```ruby
  option_family(
    aliased_resource: 'environment',
    description: _('Puppet environment'),
    deprecation: _("Use %s instead") % '--puppet-environment[-id]'
    deprecated: { '--environment' => _("Use %s instead") % '--puppet-environment[-id]',
                  '--environment-id' => _("Use %s instead") % '--puppet-environment[-id]'}
  ) do
    parent '--environment-id', 'ENVIRONMENT_ID', _(''),
           format: HammerCLI::Options::Normalizers::Number.new,
           attribute_name: :option_environment_id
    child '--environment', 'ENVIRONMENT_NAME', _('Environment name'),
          attribute_name: :option_environment_name
  end

  # $ hammer command --help:
  # ...
  #  Options:
  #    --environment[-id]               Puppet environment (Deprecated: Use --puppet-environment[-id] instead)
  # ...

  # $ hammer full-help:
  # ...
  #  Options:
  #    --environment   ENVIRONMENT_NAME    Environment name (--environment is deprecated: Use --puppet-environment[-id] instead)
  #    --environment-id   ENVIRONMENT_ID    (--environment-id is deprecated: Use --puppet-environment[-id] instead)
  # ...
```

### Option builders
Hammer commands offer option builders that can be used for automatic option generation.
See [documentation page](option_builders.md#option-builders) dedicated to this topic for more details.

### Option normalizers
Another option-related feature is a set of normalizers for specific option types. They validate and preprocess
option values. Each normalizer has a description of the format it accepts. This description is printed
in commands' help.

See [our tutorial](option_normalizers.md#option-normalizers) if you want to create your custom normalizer.

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

### Advanced option evaluation

Sometimes it is necessary to tune or validate the option values based on other parameters given on CLI.
An example could be setting default values based on other options, values lookup in a DB, etc.
The right place for this are option processors. There are two basic kinds of option processors in hammer:
- *option sources* - they provide values for the options, descendants of `HammerCLI::Options::Sources::Base`
- *option validators* - they check if the options values are valid, descendants of `HammerCLI::Options::Validators::Base`

Option sources and validators can be mixed together. For example it's possible to collect options from the command line,
do some validation on them and then continue with collecting options from a different source.
The whole set of processors is invoked only once per command call. The processing is triggered by a first call
to the `options` or `all_options` method, but at latest right after the option validation
(before the command's `execute` method is invoked). The order is as follows:
 1. option parsing
 1. option normalization
 1. option processors execution (sources and validators)
 1. `execute` invocation

#### Default option sources

Abstract Hammer command uses two default option sources -
`HammerCLI::Options::Sources::CommandLine` responsible for intial population of the options and
`HammerCLI::Options::Sources::SavedDefaults` adding defaults managed by the `defaults` command.

The default option sources are wrapped in `DefaultInputs` processor list so that it's possible to easily place
custom sources before or behind all the default ones.
The full default hierarchy is:

```
- DefaultInputs
    - CommandLine
    - SavedDefaults (present only when defaults are enabled)
```

By overriding `option_sources` method in a command it is possible to add custom option sources
for various tasks to the list. The option sources are evaluated one by one each being given output
of the previous one as its input so the order in which the sources are listed matters.

#### Option validation
Hammer provides extended functionality for validating options.

First of all there is a DSL for validating combinations of options:
```ruby
validate_options do
  all(:option_name, :option_surname).required  # requires all the options
  option(:option_age).required          # requires a single option,
                                        # equivalent of :required => true in option declaration
  any(:option_email, :option_phone).required   # requires at least one of the options

  # It is possible to create more complicated constructs.
  # This example requires either the full address or nothing
  if any(:option_street, :option_city, :option_zip).exist?
    all(:option_street, :option_city, :option_zip).required
  end

  # Here you can reject all address related option when --no-address is passed
  if option(:option_no_address).exist?
    all(:option_street, :option_city, :option_zip).rejected
  end
end

```

It's possible to insert a validation block on a certain place in the option processor chain:
```ruby
validate_options(:after, 'DefaultInputs') do
  # ...inserts the validation block after DefaultInputs option source
end

validate_options(:prepend) do
  # ...adds validation to the first place in the queue
end

# Following insert modes can be used:
# before, after, append, prepend (the default behavior)
```

Alternatively the functionality can be extracted in a validator object that can be shared by multiple commands:

```ruby
validate_options(:after, 'DefaultInputs', validator: Custom::Validator.new)

```

`validate_options` adds validators into a specific command class and they aren't inherited with subclasses.
Inheritable validators can be created command's `add_validators` method.


### Adding subcommands
Commands in the CLI can be structured into a tree of parent commands (nodes) and subcommands (leaves).
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
        print_message "Hello %s!" % (option_ name || "World")
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
when you have a growing number of subcommands. See how it works in the following example:

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

#### Aliasing subcommands

Commands can have two or more names, e.g. aliases. To support such functionality
simple name addition could be used via `command_name` or `command_names` method:
```ruby
module HammerCLIHello

  class SayCommand < HammerCLI::AbstractCommand

    class GreetingsCommand < HammerCLI::AbstractCommand
      command_name 'hello'
      command_name 'hi'
      # or use can use other method:
      command_names 'hello', 'hi'

      desc 'Say Hello World!'
      # ...
    end

    autoload_subcommands
  end

  HammerCLI::MainCommand.subcommand 'say', "Say something", HammerCLIHello::SayCommand
end
```

### Conflicting subcommands
It can happen that two different plugins define subcommands with the same name by accident.
In such situations `subcommand` will throw an exception. If this is intentional and you
want to redefine the existing command, use `subcommand!`.
This method does not throw exceptions, replaces the original subcommand, and leaves
a message in a log for debugging purposes.


### Removing subcommands
If your plugin needs to disable an existing subcommand, you can use `remove_subcommand` for this.

```ruby
  HammerCLI::MainCommand.remove_subcommand 'say'
```

Call to this action is automatically logged.


### Lazy-loaded subcommands
In some cases it's beneficial to load the command classes lazily at the time when they
are really needed. It can save some time in CLIs containing many commands with time-consuming
initialization.

Such commands have to be placed in a separate file (`hammer_cli_hello/say.rb` in our case).
Following construct registers the command as lazy-loaded. CLI then requires the file
when it needs the command class for the first time.

```ruby
HammerCLI::MainCommand.lazy_subcommand(
  'say',                        # command's name
  'Say something',              # description
  'HammerCLIHello::SayCommand', # command's class in a string
  'hammer_cli_hello/say'        # require path of the file
)
```

### Deprecated commands
To mark a command as deprecated use the `:warning` option as follows:

```ruby
HammerCLI::MainCommand.lazy_subcommand(
  'say',                        # command's name
  'Say something',              # description
  'HammerCLIHello::SayCommand', # command's class in a string
  'hammer_cli_hello/say',       # require path of the file
  warning: _('This command is deprecated and will be removed.')
)
```
Or you can mark a command in its definition:

```ruby
class SayCommand < HammerCLI::AbstractCommand

  class HelloCommand < HammerCLI::AbstractCommand
    warning 'This command is deprecated and will be removed.'
    command_name 'hello'
    desc 'Say Hello World!'
    # ...
  end
  # ...

  autoload_subcommands
end
```
### Printing some output
We've mentioned above that it's not recommended practice to print output
directly with `puts` in Hammer. The reason is we separate definition
of the output from its interpretation. Hammer uses so called _output adapters_
that can modify the output format.

The detailed documentation on adapters and related things is [here](output.md#adapters).

#### Printing messages
Very simple, just call
```ruby
print_message(msg)
```

#### Printing hash records
Typical usage of a CLI is interaction with some API. In many cases it's listing
some records returned by the API.

Hammer comes with support for selecting and formatting of hash record fields.
You first create an _output definition_ that you apply to your data. The result
is a collection of fields, each having its type. The collection is then passed to an
_output adapter_ which handles the actual formatting and printing.

Adapters support printing by chunks, e.g. if you want to print a large set of
data (1000+ records), but you make several calls to the server instead of one,
you may want to print received data right away instead of waiting for the rest.
This can be achieved via `:current_chunk` option for
`print_collection` and `print_data` methods. Allowed values for `:current_chunk`
are `:first`, `:another`, `:last`. By default adapters use `:single` value that
means only one record will be printed.

##### Printing by chunks
```ruby
# ...
  def execute
    loop do
      # ...
      data = send_request
      print_data(data, current_chunk: :first)
      # ...
      data = send_request
      print_data(data, current_chunk: :another)
      # ...
      data = send_request
      print_data(data, current_chunk: :last)
    end
  end
# ...
```

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

_NOTE_: Every field can be arranged in so-called field sets. All the fields by default go to `'DEFAULT'` and `'ALL'` sets. Fields which are in the `'DEFAULT'` set will be printed by default. To see printed other field sets, use predefined option `--fields NAME`, where `NAME` is a field set name in ALLCAPS.
```ruby
class Command < HammerCLI::AbstractCommand
  # To be able to select fields which should be printed
  use_option :fields

  output do
    # Simple field with a label. The first parameter is the key in the printed hash.
    field :id, 'ID'

    # Fields can have types. The type determines how the field is printed.
    # All available types are listed below.
    # Here we want the roles to act as list.
    field :roles, 'System Roles', Fields::List

    # Label is used for grouping fields.
    label 'Contacts', sets: ['ADDITIONAL', 'ALL'] do
      field :email, 'Email'
      field :phone, 'Phone No.'
    end

    # From is used for accessing nested fields.
    from :timestamps do
      # See how date gets formatted in the output
      field :created, 'Created At', Fields::Date
    end
  end

  def execute
    records = retrieve_data
    print_record(          # <- printing utility of AbstractCommand
      output_definition,   # <- method for accessing fields defined in the block 'output'
      records              # <- the data to print
    )
    return HammerCLI::EX_OK
  end

end
```

Using the base adapter the output will look like:
```
ID:            1
System Roles:  Admin, Editor
Name:          Tom Sawyer
Created At:    2012/12/18 15:24:42

ID:            2
System Roles:  Admin
Name:          Huckleberry Finn
Created At:    2012/12/18 15:25:00
```

Using the base adapter with `--fields ALL` or `--fields DEFAULT,ADDITIONAL` the output will look like:
```
ID:            1
System Roles:  Admin, Editor
Name:          Tom Sawyer
Created At:    2012/12/18 15:24:42
Contacts:
  Email:       tom@email.com
  Phone No.:   123456111

ID:            2
System Roles:  Admin
Name:          Huckleberry Finn
Created At:    2012/12/18 15:25:00
Contacts:
  Email:       huckleberry@email.com
  Phone No.:   123456222
```

_NOTE_: `--fields` as well lets you to print desired fields only. E.g. to see the users' emails without any additional information use `--fields contacts/email`:
```
Email:       tom@email.com

Email:       huckleberry@email.com
```

You can optionally use the output definition from another command as a base and extend it with
additional fields. This is helpful when there are two commands, one listing brief data and
another one showing details. Typically it's list and show.
```ruby
class ShowCommand < HammerCLI::AbstractCommand

  output ListCommand.output_definition do
    # additional fields
  end

  # ...
end
```


All Hammer field types are:
 * __Date__
 * __Id__ - Used to mark ID values, current print adapters have support for turning id printing on/off.
 See hammer's parameter `--show-ids`.
 * __List__
 * __KeyValue__ - Formats hashes containing `:name` and `:value`
 * __Collection__ - Enables to render subcollections. Takes a block with another output definition.

The default adapter for every command is the Base adapter. It is possible to override
the default one by redefining command's method `adapter`.

```ruby
def adapter
  # return :base, :table, :csv or name of your own adapter here
  :table
end
```

#### Deprecating and replacing fields
To deprecate a field, add `:deprecated => true` as an option for the field. This will print a warning message to stderr whenever the field is displayed. Consider removing this field from the default set so it is not displayed without a `--fields` param:

```
field :dep_fld, _("Deprecated field"), Fields::Field, :sets => ['ALL'], :deprecated => true
```

Example output:

```
$ hammer foo info --fields "Deprecated field"
Warning: Field 'Deprecated field' is deprecated and may be removed in future versions.
Deprecated field: bar
```

Additionally, a field may be 'replaced by' another field using `:replaced_by => [_('Path'), _('To'), _('New'), _('Field')].join('/')`. Translating each string segment independently ensures the resulting translation is identical to the path the user will enter. This will mark the replaced field as deprecated and print a warning message to stderr whenever the field is displayed:

```
field :rep_fld, _("Old field"), Fields::Field, :sets => ['ALL'], :replaced_by => [_('Bar'), _('New Field')].join('/')
```

Example output:

```
$ hammer foo info --fields "Old field"
Warning: Field 'Foo/Old field' is deprecated. Consider using 'Bar/New field' instead.
Foo:
  Old field: bar
```

#### Verbosity
Currently Hammer [defines](https://github.com/theforeman/hammer-cli/blob/master/lib/hammer_cli/verbosity.rb) three basic verbose modes:
  * __QUIET__ - Prints nothing
  * __UNIX__ - Prints data only
  * __VERBOSE__ - Prints data and other messages

By default Hammer works in `VERBOSE` mode, but it can be changed with specific option (see `hammer --help`) or in the configuration file.

If you want to force some messages to be printed with `print_message` in `UNIX` mode for example, you can specify `verbosity` of this message:
```ruby
class MyCommand < HammerCLI::Apipie::Command
  def execute
    print_message("Hello, %{name}!", { name: 'Jason' }, verbosity: HammerCLI::V_UNIX)
  end
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
rather than handle it and return error codes. This approach guarantees that error messages are logged and
printed consistently and correct exit codes are returned.


#### Configuration
Values form config files are accesible via class `HammerCLI::Settings`.
It's method `get` returns either the value or nil when it's not found.

Config values belonging to a specific plugin must be nested under
the plugin's name (without the prefix 'hammer_cli_') in config files.

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

There are more ways where to place your config file for hammer.
The best practice is to place module's configuration into a separate file named by
the module. In this example it would be `~/.hammer/cli.modules.d/hello_world.yml`.

Read more about configuration locations in [the settings howto](installation.md#configuration).
