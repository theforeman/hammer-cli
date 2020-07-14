### Installation from RPMs

#### Step 1: set up yum repositories

For Foreman 1.3 stable, the hammer packages are part of your installation repo and you can skip this step.

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
yum install tfm-rubygem-hammer_cli
```

#### Step 3: install plugins
Currently, there are two plugins, both available as rpm packages.

 - commands for managing foreman

```bash
yum install tfm-rubygem-hammer_cli_foreman
```

 - commands for managing [katello](https://github.com/Katello/katello)

```bash
yum install tfm-rubygem-hammer_cli_katello
```

To install any other hammer plugin just make sure the appropriate gem is installed and follow with the [configuration](installation.md#configuration).
