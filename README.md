Hammer - the CLI tool (not only) for Foreman
============================================


Hammer is a generic [clamp-based](https://github.com/mdub/clamp) CLI framework. 
Hammer-cli provides just the core functionality. The core is extensible using plugins that contain application-specific commands.

This architecture allows for easy customization according to your application. Nearly any Ruby script can be turned into a Hammer command, so the possibilities are endless.

Available plugins are currently:
  - [hammer-cli-foreman](https://github.com/theforeman/hammer-cli-foreman)  - commands corresponding to Foreman API
  - [hammer-cli-katello-bridge](https://github.com/theforeman/hammer-cli-katello-bridge) - set of commands provided by Katello CLI

You also can easily add custom commands for your specific use, such as bulk actions or admin tasks.


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

 - 1:1 bridge to [katello cli](https://github.com/Katello/katello)

```bash
yum install rubygem-hammer_cli_katello_bridge
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
$ apt-get install ruby-hammer-cli-katello-bridge
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
$ gem install hammer_cli_katello_bridge
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

### Format and locations

Configuration is set based on the following files, loaded in this order:

 - ```/etc/foreman/cli_config.yml```.
 - ```~/.foreman/cli_config.yml```
 - ```./config/cli_config.yml``` (config dir in CWD)
 - custom location specified on command line - ```-c CONF_FILE_PATH```

Later files have precedence if they redefines the same option.

Hammer uses yaml formatting for its configuration. The config file template is contained in the hammer_cli gem

 ```bash
gem contents hammer_cli|grep cli_config.template.yml
```
and can be copied to one of the locations above and changed as needed. The packaged version of hammer copies the template to /etc for you.


### Plugins

Plugins are disabled by default. You have to edit the config file and enable them manually under ```modules``` option, as can be seen in the sample config below.

Plugin specific configuration should be nested under plugin's name.

### Options

 - ```:log_dir: <path>``` - directory where the logs are stored. The default is ```/var/log/foreman/``` and the log file is named ```hammer.log```
 - ```:log_level: <level>``` - logging level. One of ```debug```, ```info```, ```warning```, ```error```, ```fatal```
 - ```:log_owner: <owner>``` - logfile owner
 - ```:log_group: <group>``` - logfile group
 - ```:log_size: 1048576``` - size in bytes, when exceeded the log rotates. Default is 1MB
 - ```:watch_plain: false``` - turn on/off syntax highlighting of data being logged in debug mode

### Sample config

```yaml
:modules:
    - hammer_cli_foreman
    - hammer_cli_katello_bridge

:foreman:
    :host: 'https://localhost/'
    :username: 'admin'
    :password: 'changeme'

:katello_bridge:
    :cli_description: '/home/mbacovsk/work/theforeman/hammer-cli-katello-bridge/katello.json'


:log_dir: '/var/log/foreman/'
:log_level: 'debug'
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
    architecture                  Manipulate Foreman's architectures.
    global_parameter              Manipulate Foreman's global parameters.
    compute_resource              Manipulate Foreman's compute resources.
    domain                        Manipulate Foreman's domains.
    fact                          Search Foreman's facts.
    report                        Browse and read reports.
    puppet_class                  Browse and read reports.
    host                          Manipulate Foreman's hosts.
    hostgroup                     Manipulate Foreman's hostgroups.
    location                      Manipulate Foreman's locations.
    medium                        Manipulate Foreman's installation media.
    model                         Manipulate Foreman's hardware models.
    os                            Manipulate Foreman's operating system.
    organization                  Manipulate Foreman's organizations.
    partition_table               Manipulate Foreman's partition tables.
    proxy                         Manipulate Foreman's smart proxies.
    subnet                        Manipulate Foreman's subnets.
    template                      Manipulate Foreman's config templates.
    about                         status of the katello server and its subcomponents
    activation_key                activation key specific actions in the katello server
    admin                         various administrative actions
    changeset                     changeset specific actions in the katello server
    client                        client specific actions in the katello server
    content                       content namespace command
    distribution                  repo specific actions in the katello server
    distributor                   distributor specific actions in the katello server
    environment                   environment specific actions in the katello server
    errata                        errata specific actions in the katello server
    gpg_key                       GPG key specific actions in the katello server
    node                          node specific actions in the katello server
    org                           organization specific actions in the katello server
    package                       package specific actions in the katello server
    package_group                 package group specific actions in the katello server
    permission                    permission specific actions in the katello server
    ping                          get the status of the katello server
    product                       product specific actions in the katello server
    provider                      provider specific actions in the katello server
    puppet_module                 puppet module specific actions in the katello server
    repo                          repo specific actions in the katello server
    shell                         run the cli as a shell
    sync_plan                     synchronization plan specific actions in the katello server
    system                        system specific actions in the katello server
    system_group                  system group specific actions in the katello server
    task                          commands for retrieving task information
    user                          user specific actions in the katello server
    user_role                     user role specific actions in the katello server
    version                       get the version of the katello server

Options:
    -v, --verbose                 be verbose
    -c, --config CFG_FILE         path to custom config file
    -u, --username USERNAME       username to access the remote system
    -p, --password PASSWORD       password to access the remote system
    --version                     show version
    --show-ids                    Show ids of associated resources
    --csv                         Output as CSV (same as --adapter=csv)
    --output ADAPTER              Set output format. One of [base, table, silent, csv]
    --csv-separator SEPARATOR     Character to separate the values
    -P, --ask-pass                Ask for password
    --autocomplete LINE           Get list of possible endings
    -h, --help                    print help
```


And you are Done. Your hammer client is configured and ready to use.


Autocompletion
--------------

It is necessary to copy the hammer_cli_complete script to the bash_completion.d directory.

    $ sudo cp hammer-cli/hammer_cli_complete /etc/bash_completion.d/

Then after starting a new shell the completion should work.


License
-------

This project is licensed under the GPLv3+.


Acknowledgements
----------------

Thanks to Brian Gupta for the initial work and a great name.
