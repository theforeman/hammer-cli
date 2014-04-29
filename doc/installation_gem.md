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

 - commands for managing [katello](https://github.com/Katello/katello)

```bash
$ gem install hammer_cli_katello
```

#### Step 3: enable and configure the plugins
Installation via gems unfortunately won't create configuration files.
You'll have to copy them to proper locations manually.
Please check our [configuration instructions](installation.md#configuration).

