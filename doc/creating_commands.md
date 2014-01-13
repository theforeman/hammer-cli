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
on that topic. However unlike in Clamp, the option accessors in Hammer are created with prefix 'option_', to avoid
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


### Option validation
Hammer provides extended functionality for validating options.

#### DSL
First of all there is a dsl for validating combinations of options:
```ruby
validate_options do
  all(:option_name, :option_surname).required  # requires all the options
  option(:option_age).required          # requires a single option,
                                 # equivalent of :required => true in option declaration
  any(:option_email, :option_phone).required   # requires at least one of the options

  # Tt is possible to create more complicated constructs.
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

#### Option normalizers
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


### Removing subcommands
If your plugin needs to disable existing subcommand, you can use `remove_subcommand` for this.

```ruby
  HammerCLI::MainCommand.remove_subcommand 'say'
```

Call to this action is automatically logged.


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
class Command < HammerCLI::AbstractCommand

  output do
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

  def execute
    records = retrieve_data
    print_records(         # <- printing utility of AbstractCommand
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

You can optionally use output definition from another command as a base and extend it with
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

