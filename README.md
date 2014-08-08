Hammer - the CLI tool (not only) for Foreman
============================================

Hammer is a generic [clamp-based](https://github.com/mdub/clamp) CLI framework.
Hammer-cli provides just the core functionality. The core is extensible using plugins that contain application-specific commands.

This architecture allows for easy customization according to your application. Nearly any Ruby script can be turned into a Hammer command, so the possibilities are endless.

Available plugins are currently:
  - [hammer-cli-foreman](https://github.com/theforeman/hammer-cli-foreman) - commands corresponding to Foreman API
  - [hammer-cli-katello](https://github.com/theforeman/hammer-cli-katello) - commands for managing Katello

You also can easily add custom commands for your specific use, such as bulk actions or admin tasks.

Check out the [release notes](doc/release_notes.md#release-notes) to see what's new in the latest version.

Installation
------------
We build rpms, debs and gems. Alternatively you can install hammer from a git checkout.
See our [installation and configuration instuctions](doc/installation.md#installation).


Having issues?
--------------
If one of hammer commands doesn't work as you would expect, you can run `hammer -d ...` to get
full debug output from the loggers. It should give you an idea what went wrong.

If you have questions, don't hesitate to contact us on `foreman-users@googlegroups.com` or
the `Freenode#theforeman` IRC channel.


Further reading
---------------
If you're interested in hammer and want to develop some plugins for Foreman
or use it as a base for your own CLI, read
[the developer docs](doc/developer_docs.md#hammer-development-docs).


License
-------
This project is licensed under the GPLv3+.


Acknowledgements
----------------
Thanks to Brian Gupta for the initial work and a great name.
