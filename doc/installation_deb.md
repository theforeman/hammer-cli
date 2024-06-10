### Installation from DEBs

#### Step 1: setup apt repositories

Since Foreman 1.3 the hammer packages are part of your installation repo.
It is only necessary to setup apt repositories if you are installing Hammer separatly from Foreman.

You can choose from a specific version or nightly repo.
Nightly has more recent version of hammer packages that have only had limited testing so there is a higher risk of issues.

Here are a few examples for combinations of Linux-distributions and Foreman releases.
Remember to adjust these as necessary, visit http://deb.theforeman.org/ for up to date information.

##### Ubuntu Focal (20.04) with Foreman 3.10

```bash
mkdir -p /etc/apt/keyrings
wget -qO- https://deb.theforeman.org/foreman.asc > /etc/apt/keyrings/foreman.asc
echo "deb [signed-by=/etc/apt/keyrings/foreman.asc] http://deb.theforeman.org/ focal 3.10" > /etc/apt/sources.list.d/foreman.list
```

##### Debian Bullseye (11) with Foreman nightly

```bash
mkdir -p /etc/apt/keyrings
wget -qO- https://deb.theforeman.org/foreman.asc > /etc/apt/keyrings/foreman.asc
echo "deb [signed-by=/etc/apt/keyrings/foreman.asc] http://deb.theforeman.org/ bullseye nightly" > /etc/apt/sources.list.d/foreman.list
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

