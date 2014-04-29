### Installation from SOURCE

If you can install hammer from git checkouts, you will just need `rake` installed on your system.

#### Step 1: clone the sources
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

and optionally other plugins.


#### Step 2: enable and configure the plugins
You'll have to copy configuration files to proper locations manually.
Please check our [configuration instructions](installation.md#configuration)
and see how to proceed.

