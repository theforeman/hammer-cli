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
wget -q https://deb.theforeman.org/foreman.asc -O- | apt-key add -
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

 - commands for managing [katello](https://github.com/Katello/katello)

```bash
$ apt-get install ruby-hammer-cli-katello
```

To install any other hammer plugin just make sure the appropriate gem is installed and follow with the [configuration](installation.md#configuration).
