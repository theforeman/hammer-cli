Installation
------------

Hammer CLI is packaged for the following RPM based distributions:

 - RHEL and derivatives, version 6
 - Fedora 18, 19
 - Debian Wheezy, Squeezy
 - Ubuntu Precise

### Installation from RPMs

#### Step 1: setup yum repositories

For Foreman 1.3 stable the hammer packages are part of your installation repo and you can skip this step.

You can choose from stable or nightly repo. Nightly has more recent version of hammer packages, but it was subject to less testing so there is a higher risk of issues.
Add the Foreman yum repository to your yum repo files. For Fedora installations replace 'el6' with 'f18' or 'f19' as appropriate.


Using stable

```bash
yum -y install http://yum.theforeman.org/releases/1.3/el6/x86_64/foreman-release.rpm
```

or nightly

```bash
cat > /etc/yum.repos.d/foreman.repo << EOF
[foreman]
name=Foreman Nightly
baseurl=http://yum.theforeman.org/nightly/el6/x86_64
gpgcheck=0
enabled=1
EOF
```

On RHEL systems you will also have to add [EPEL repository](https://fedoraproject.org/wiki/EPEL) as it contains some of the required dependencies.


#### Step 2: install hammer core

```bash
yum install rubygem-hammer_cli
```

#### Step 3: install plugins
Currently, there are two plugins, both available as rpm packages.

 - commands for managing foreman

```bash
yum install rubygem-hammer_cli_foreman
```

 - commands for katello [katello cli](https://github.com/Katello/katello)

```bash
yum install rubygem-hammer_cli_katello
```

To install any other hammer plugin just make sure the appropriate gem is installed and follow with the configuration.


### Installation from DEBs

#### Step 1: setup apt repositories

For Foreman 1.3 stable the hammer packages are part of your installation repo and you can skip this step.

You can choose from stable or nightly repo. Nightly has more recent version of hammer packages, but it was subject to less testing so there is a highr risk of issues.

Choose stable (don't forget to replace "squeeze" with version name of your system)

```bash
echo "deb http://deb.theforeman.org/ squeeze stable" > /etc/apt/sources.list.d/foreman.list
```

or nightly

```bash
echo "deb http://deb.theforeman.org/ squeeze nightly" > /etc/apt/sources.list.d/foreman.list
```

and update the keys

```bash
wget -q http://deb.theforeman.org/foreman.asc -O- | apt-key add -
```

#### Step 2: install hammer core

```bash
apt-get update && apt-get install ruby-hammer-cli
```

#### Step 3: install plugins
Currently, there are two plugins, both available as deb packages.

 - commands for managing foreman

```bash
$ apt-get install ruby-hammer-cli-foreman
```

 - 1:1 bridge to [katello cli](https://github.com/Katello/katello)

```bash
$ apt-get install ruby-hammer-cli-katello
```

To install any other hammer plugin just make sure the appropriate gem is installed and follow with the configuration.


### Installation from GEMs

Make sure you have ```gem``` command installed on your system

#### Step 1: install hammer core

```bash
$ gem install hammer_cli
```

#### Step 2: install plugins
Currently, there are two plugins, both available on rubygems.org

 - commands for managing foreman

```bash
$ gem install hammer_cli_foreman
```

 - 1:1 bridge to [katello cli](https://github.com/Katello/katello)

```bash
$ gem install hammer_cli_katello
```

To install any other hammer plugin just install the appropriate gem and follow with the configuration.


### Installation from SOURCE

If you can install hammer from git checkouts, you will just need ```rake``` installed on your system.
Clone and install CLI core

```bash
$ git clone https://github.com/theforeman/hammer-cli.git
$ cd hammer-cli
$ rake install
$ cd ..
```

clone plugin with foreman commands

```bash
$ git clone https://github.com/theforeman/hammer-cli-foreman.git
$ cd hammer-cli-foreman
$ rake install
$ cd ..
```

and optionally other plugins via any of the methods mentioned above.


Configuration
-------------

### Locations

Configuration is by default looked for in the following directories, loaded in this order:

 - ```RbConfig::CONFIG['sysconfdir']/hammer/``` (The actual value depends on your operatingsystem and ruby defaults.)
 - ```/etc/hammer/```
 - ```~/.hammer/```
 - ```./config/``` (config dir in CWD)
 - custom location (file or directory) specified on command line - ```-c CONF_FILE_PATH```

In each of these directories hammer is trying to load ```cli_config.yml``` and anything in
the ```cli.modules.d``` subdirectory which is place for specific configuration of hammer modules.

Later directories and files have precedence if they redefine the same option. Files from ```cli.modules.d```
are loaded in alphabetical order.

### Format

Hammer uses YAML formatting for its configuration. The configuration templates are contained in the hammer_cli gem

 ```bash
gem contents hammer_cli|grep template.yml
```
and can be copied to one of the locations above and changed as needed. The packaged version of hammer copies the template to /etc for you.


### Options

 - ```:log_dir: <path>``` - directory where the logs are stored. The default is ```/var/log/hammer/``` and the log file is named ```hammer.log```
 - ```:log_level: <level>``` - logging level. One of ```debug```, ```info```, ```warning```, ```error```, ```fatal```
 - ```:log_owner: <owner>``` - logfile owner
 - ```:log_group: <group>``` - logfile group
 - ```:log_size: 1048576``` - size in bytes, when exceeded the log rotates. Default is 1MB
 - ```:watch_plain: <bool>``` - turn on/off syntax highlighting of data being logged in debug mode
 - ```:log_api_calls: <bool>``` - turn on logging of the communication with API (data sent and received)

In the ```:ui``` section there is

 - ```:interactive: <bool>``` - whether to ask user for input (pagination, passwords)
 - ```:per_page: <records>``` - number of records per page if server sends paginated data
 - ```:history_file: <path>``` - file where the hammer shell store its history (default is ```~/.hammer_history```)


#### Sample config

```yaml
:ui:
  :interactive: true
  :per_page: 20
  :history_file: '~/.hammer/history'

:watch_plain: false

:log_dir: '~/.hammer/log'
:log_level: 'error'
:log_api_calls: false
```

### Plugins

Plugins are disabled by default. To enable plugin create configuration file in ```cli.modules.d``` and add```:enable_plugin: true``` in it. Plugin specific configuration should be nested under plugin's name (without the ```hammer_cli_``` prefix).

In the example we assume the gem ```hammer_cli_foreman``` with the Foreman plugin is installed. Then the plugin configuration
in ```~/.hammer/cli.plugins.d/foreman.yml``` should look as follows:

```yaml
:foreman:
    :enable_module: true
    :host: 'https://localhost/'
    :username: 'admin'
    :password: 'changeme'
```

Use the hammer
--------------

Confirm your setup by running ```$ hammer -h``` and check that the desired commands are listed.

```
$ hammer -h
Usage:
    hammer [OPTIONS] SUBCOMMAND [ARG] ...

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    activation-key                Manipulate activation keys.
    architecture                  Manipulate architectures.
    compute_resource              Manipulate compute resources.
    domain                        Manipulate domains.
    environment                   Manipulate environments.
    fact                          Search facts.
    global_parameter              Manipulate global parameters.
    gpg                           manipulate GPG Key actions on the server
    host                          Manipulate hosts.
    hostgroup                     Manipulate hostgroups.
    lifecycle-environment         manipulate lifecycle_environments on the server
    location                      Manipulate locations.
    medium                        Manipulate installation media.
    model                         Manipulate hardware models.
    organization                  Manipulate organizations
    os                            Manipulate operating system.
    partition_table               Manipulate partition tables.
    ping                          get the status of the server
    product                       Manipulate products.
    provider                      Manipulate providers
    proxy                         Manipulate smart proxies.
    puppet_class                  Search puppet modules.
    report                        Browse and read reports.
    repository                    Manipulate repositories
    repository-set                manipulate repository sets on the server
    sc_param                      Manipulate smart class parameters.
    shell                         Interactive shell
    subnet                        Manipulate subnets.
    subscription                  Manipulate subscriptions.
    system                        manipulate systems on the server
    systemgroup                   Manipulate system groups
    task                          Tasks related actions.
    template                      Manipulate config templates.
    user                          Manipulate users.

Options:
    --autocomplete LINE           Get list of possible endings
    --csv                         Output as CSV (same as --output=csv)
    --csv-separator SEPARATOR     Character to separate the values
    --interactive INTERACTIVE     Explicitly turn interactive mode on/off
                                  One of true/false, yes/no, 1/0.
    --output ADAPTER              Set output format. One of [base, table, silent, csv]
    --show-ids                    Show ids of associated resources
    --version                     show version
    -c, --config CFG_FILE         path to custom config file
    -h, --help                    print help
    -p, --password PASSWORD       password to access the remote system
    -u, --username USERNAME       username to access the remote system
    -v, --verbose                 be verbose
```


And you are done. Your hammer client is configured and ready to use.


Autocompletion
--------------

It is necessary to copy the hammer_cli_complete script to the bash_completion.d directory.

    $ sudo cp hammer-cli/hammer_cli_complete /etc/bash_completion.d/

Then after starting a new shell the completion should work.
