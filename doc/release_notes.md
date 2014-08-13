Release notes
=============

### 0.1.2
* Allow override of request options, e.g. :response => :raw
* Lazy loaded subcommands ([#6761](http://projects.theforeman.org/issues/6761))
* I18n - fixed error message + docs
* I18n - fix apipie warning string to be properly extracted
* I18n - add mark_translated to highlight extracted strings
* I18n - add en_GB locale
* I18n - extracting new, pulling from tx
* Project-Id-Version is fixed after tx pull
* Restrict ci_reporter gem to less than 2.0.0 to fix CI ([#6779](http://projects.theforeman.org/issues/6779))
* Fixed dependency on simplecov
* Parameters are not wrapped ([#6343](http://projects.theforeman.org/issues/6343))
* Rest-client > 1.7 does not support ruby 1.8 ([#6534](http://projects.theforeman.org/issues/6534))
* Exit cleanly when EOF/ctrl+d given in shell ([#6148](http://projects.theforeman.org/issues/6148))
* Fix incorrect --server help text ([#6219](http://projects.theforeman.org/issues/6219))
* Fixed wrong config file path in installation docs
* Empty list in csv adapter does not work ([#6238](http://projects.theforeman.org/issues/6238))
* Resource name mapping ([#6092](http://projects.theforeman.org/issues/6092))
* Tests for EnumList normalizer, fixed missing quotes in description
* ListEnum normalizer
* Add --server cli option ([#6219](http://projects.theforeman.org/issues/6219))
* CSV handles collection or container ([#5111](http://projects.theforeman.org/issues/5111))
* build_options configurable with block ([#5747](http://projects.theforeman.org/issues/5747))
* Add pkg:generate_source task to generate gem ([#5793](http://projects.theforeman.org/issues/5793))


### 0.1.1
* Removed `log_api_calls` setting
* Updated documentation
* String#format fixed to behave consistently with %
* Fix for ignoring cases where output record is null ([#5605](http://projects.theforeman.org/issues/5605))
* Messages for clamp translated ([#4475](http://projects.theforeman.org/issues/4475))
* Read and write commands merged ([#4311](http://projects.theforeman.org/issues/4311))
* Introduced option builders ([#4311](http://projects.theforeman.org/issues/4311))
* Add support for boolean fields ([#5025](http://projects.theforeman.org/issues/5025))
* Skip missing translation domains ([#4916](http://projects.theforeman.org/issues/4916))


### 0.1.0
* Updated documentation
* Fixes command description issues ([#4791](http://projects.theforeman.org/issues/4791), [#4556](http://projects.theforeman.org/issues/4556))
* Added option for debugging output ([#4861](http://projects.theforeman.org/issues/4861))
* Runs with log level 'debug' in verbose ([#4835](http://projects.theforeman.org/issues/4835))
* Loads configuration form /etc/hammer ([#4792](http://projects.theforeman.org/issues/4792))
* Numbered collections in output ([#4676](http://projects.theforeman.org/issues/4676))
* Dynamic API bindings ([#3897](http://projects.theforeman.org/issues/3897))
* Fixes subnet info in csv mode errors out ([#4531](http://projects.theforeman.org/issues/4531))
* i18n support ([#4472](http://projects.theforeman.org/issues/4472))
* shell - temporarily disable command completion on ruby 1.8
* Enable setting width to columns in table output adapter ([#4384](http://projects.theforeman.org/issues/4384))
* Enable skipping blank values in base output adapter ([#4231](http://projects.theforeman.org/issues/4231))
* Adds support for output fields containing multiline text
* Fixes --interactive=false still prompts ([#4378](http://projects.theforeman.org/issues/4378))
* Fixes completion of quoted values ([#4182](http://projects.theforeman.org/issues/4182))
* Main commands are now sorted in the help output ([#4112](http://projects.theforeman.org/issues/4112))
* Persistent history in shell ([#3883](http://projects.theforeman.org/issues/3883))
* Stores option -v into context ([#3633](http://projects.theforeman.org/issues/3633))
* Adds JSONInput formalizer ([#4246](http://projects.theforeman.org/issues/4246))
