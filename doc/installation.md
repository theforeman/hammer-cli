Installation
------------

Hammer CLI is packaged for the following RPM based distributions:

 - RHEL and derivatives, version 6
 - Fedora 18, 19
 - Debian Wheezy, Squeezy
 - Ubuntu Precise

### Select your way of installation
- [Installation from RPMs](installation_rpm.md#installation-from-rpms)
- [Installation from DEBs](installation_deb.md#installation-from-debs)
- [Installation from GEMs](installation_gem.md#installation-from-gems)
- [Installation from source](installation_source.md#installation-from-source)


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

### Manual installation
The packaged version of hammer copies the template to `/etc/hammer` for you.
When you install from gems or source you'll have to copy config files manually.

The configuration templates are contained in the hammer_cli gem

 ```bash
gem contents hammer_cli|grep template.yml
```
and can be copied to one of the locations above and changed as needed.


### Tuning options

Hammer uses [YAML](http://www.yaml.org/) formatting for its configuration.

List of existing options is available in the [configuration template file](https://github.com/theforeman/hammer-cli/blob/master/config/cli_config.template.yml)
with descriptions.


### Plugins

Plugins are disabled by default. To enable plugin create configuration file in ```cli.modules.d``` and add```:enable_plugin: true``` in it.
Plugin specific configuration must be nested under plugin's name (without the ```hammer_cli_``` prefix).

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
    architecture                  Manipulate architectures.
    compute-resource              Manipulate compute resources.
    domain                        Manipulate domains.
    environment                   Manipulate environments.
    fact                          Search facts.
    global-parameter              Manipulate global parameters.
    host                          Manipulate hosts.
    hostgroup                     Manipulate hostgroups.
    location                      Manipulate locations.
    medium                        Manipulate installation media.
    model                         Manipulate hardware models.
    organization                  Manipulate organizations.
    os                            Manipulate operating system.
    partition-table               Manipulate partition tables.
    proxy                         Manipulate smart proxies.
    puppet-class                  Search puppet modules.
    report                        Browse and read reports.
    sc-param                      Manipulate smart class parameters.
    shell                         Interactive shell
    subnet                        Manipulate subnets.
    template                      Manipulate config templates.
    user                          Manipulate users.

Options:
    --autocomplete LINE           Get list of possible endings
    --csv                         Output as CSV (same as --output=csv)
    --csv-separator SEPARATOR     Character to separate the values
    --interactive INTERACTIVE     Explicitly turn interactive mode on/off
                                  One of true/false, yes/no, 1/0.
    --output ADAPTER              Set output format. One of [silent, csv, base, table]
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
