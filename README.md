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
We build rpms, debs and gems. Alternatively you can install hammer form a git checkout. See our [installation instructions](doc/installation.md#installation) for details.


Further reading
---------------
If you're interested in hammer and want to develop some plugins for Foreman
or use it as a base for your own cli, read
[the developer docs](doc/developer_docs.md#hammer-development-docs).

License
-------

This project is licensed under the GPLv3+.


Acknowledgements
----------------

Thanks to Brian Gupta for the initial work and a great name.
