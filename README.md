Hammer - the CLI tool for Foreman
=================================

Hammer is a generic [clamp-based](https://github.com/mdub/clamp) CLI framework. Hammer-cli is just a core without any commands.

The core can be extended with plugins and customized according to your application setup. Any Ruby script can be easily turned into a command so possibilities are wide.

Currently available plugins are:
  - [hammer-cli-foreman](https://github.com/theforeman/hammer-cli-foreman)  - commands corresponding to Foreman API
  - [hammer-cli-katello-bridge](https://github.com/theforeman/hammer-cli-katello-bridge) - set of commands provided by Katello CLI

You also can easily add custom commands specific for your use, such as various bulk actions or admin tasks.



Installation instructions
-------------------------

Hammer CLI is packaged for the following RPM based distributions:

 - RHEL and derivatives, version 6
 - Fedora 18, 19


#### Step 1: setup rpm repositories
Add the Foreman's nightly rpm repository to your yum repo files. For Fedora installations replace 'el6' with 'f18' or 'f19' as appropriate.

```bash
http://yum.theforeman.org/nightly/el6/$basearch/
```

On RHEL systems you will also have to add [EPEL repository](https://fedoraproject.org/wiki/EPEL) as it contains some of the required dependencies.


#### Step 2: install hammer core
```
$ yum install rubygem-hammer_cli
```


#### Step 3: install plugins
Currently, there are two plugins, both available as rpm packages.

 - commands for managing foreman
```
$ yum install rubygem-hammer_cli_foreman
```

 - 1:1 bridge to [katello cli](https://github.com/Katello/katello)
```
$ yum install rubygem-hammer_cli_katello_bridge
```

Plugins are disabled after the installation. You have to edit the config file and enable them manually.


#### Step 4: configuration

Edit ```/etc/foreman/cli_config.yml``` or ```~/.foreman/cli_config.yml``` and uncomment lines with names of modules you've just installed to enable them:

```yaml
:modules:
# - hammer_cli_foreman
# - hammer_cli_katello_bridge
```

Confirm your setup by running ```$ hammer -h``` and see if the desired commands are listed.

You will also most likely want to change the url of the Foreman server.

```yaml
:host: 'https://localhost/'
:username: 'admin'
:password: 'changeme'
```

Done. Your hammer client is configured and ready to use.

#### Git installation
Optionally you can install hammer from git checkouts. You will need ```rake``` and ```bundler```.
Clone and install CLI core

    $ git clone git@github.com:theforeman/hammer-cli.git
    $ cd hammer-cli
    $ rake install
    $ cd ..


clone plugin with foreman commands

    $ git clone git@github.com:theforeman/hammer-cli-foreman.git
    $ cd hammer-cli-foreman
    $ rake install
    $ cd ..

and configure. Configuration is by default looked for in ```~/.foreman/``` or in ```/etc/foreman/```.
Optionally you can put your configuration in ```./config/``` or point hammer
to some other location using ```-c CONF_FILE``` option

You can start with config file template we created for you and update it to suit your needs. E.g.:

    $ cp hammer-cli/config/cli_config.template.yaml ~/.foreman/cli_config.yml




Autocompletion
--------------

It is necessary to copy script hammer_cli_complete to the bash_completion.d directory.

    $ sudo cp hammer-cli/hammer_cli_complete /etc/bash_completion.d/

Then in new shell the completion should work.


How to test
------------

Development of almost all the code was test driven.

    $ bundle install
    $ bundle exec "rake test"

should work in any of the cli related repos. Generated coverage reports are stored in ./coverage directory.

License
-------

This project is licensed under the GPLv3+.


Acknowledgements
----------------

Thanks to Brian Gupta for the initial work and a great name.
