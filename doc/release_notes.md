Release notes
=============

### 0.9.0 (2016-12-15)
* Double quotes in list type params ([#17180](http://projects.theforeman.org/issues/17180))
* API connection moved to context ([PR #227](https://github.com/theforeman/hammer-cli/pull/227)) ([#8016](http://projects.theforeman.org/issues/8016))
* Log related error messages to stderr ([#17508](http://projects.theforeman.org/issues/17508))
* Respect special chars width ([#3520](http://projects.theforeman.org/issues/3520))
* Properly detect booleans ([#17021](http://projects.theforeman.org/issues/17021))
* Support for additional text in help ([PR #222](https://github.com/theforeman/hammer-cli/pull/222)) ([#16408](http://projects.theforeman.org/issues/16408))
* Permit clamp 1.1 and higher, compatibility restored ([PR #224](https://github.com/theforeman/hammer-cli/pull/224)) ([#16973](http://projects.theforeman.org/issues/16973))
* Pin clamp to 1.0.x ([PR #223](https://github.com/theforeman/hammer-cli/pull/223)) ([#16973](http://projects.theforeman.org/issues/16973))
* Allow multiple opt validation blocks ([#16811](http://projects.theforeman.org/issues/16811))
* Check for nil default values ([PR #221](https://github.com/theforeman/hammer-cli/pull/221)) ([#16822](http://projects.theforeman.org/issues/16822))
* Use defaults in validators ([#16631](http://projects.theforeman.org/issues/16631))
* Boolean formatter prints "no" for 0 ([PR #219](https://github.com/theforeman/hammer-cli/pull/219)) ([#16406](http://projects.theforeman.org/issues/16406))
* Fix mark_translated in cli_config ([PR #216](https://github.com/theforeman/hammer-cli/pull/216)) ([#16470](http://projects.theforeman.org/issues/16470))

### 0.8.0 (2016-09-01)
* Fix tests with rest-client >= 2.0.0 ([#16404](http://projects.theforeman.org/issues/16404))
* Add missing apostrophe in error message ([#16316](http://projects.theforeman.org/issues/16316))
* Improve error for missing ~/.hammer directory ([#16312](http://projects.theforeman.org/issues/16312))
* Option deprecation indication in help ([PR #212](https://github.com/theforeman/hammer-cli/pull/212)) ([#16161](http://projects.theforeman.org/issues/16161))
* Preserve original exception message ([#14436](http://projects.theforeman.org/issues/14436))
* Added exception handling while parsing configuration file. ([#14436](http://projects.theforeman.org/issues/14436))
* Gettext speed improvements ([PR #198](https://github.com/theforeman/hammer-cli/pull/198)) ([#14092](http://projects.theforeman.org/issues/14092))
* Explicitly list man page in gemspec files ([PR #210](https://github.com/theforeman/hammer-cli/pull/210)) ([#7453](http://projects.theforeman.org/issues/7453))
* Adds man page to hammer ([PR #163](https://github.com/theforeman/hammer-cli/pull/163)) ([#7453](http://projects.theforeman.org/issues/7453))
* I18n - fix extraction of variables in strings ([PR #209](https://github.com/theforeman/hammer-cli/pull/209))

### 0.7.0 (2016-06-14)
* Let print adapters decide whether to paginate ([#15257](http://projects.theforeman.org/issues/15257))
* Add support for testing values in option  validation ([#13832](http://projects.theforeman.org/issues/13832))
* Add one_of constraint for option validator ([#13832](http://projects.theforeman.org/issues/13832))
* Descriptions from Apipie will not contain unescaped HTML ([#14598](http://projects.theforeman.org/issues/14598))
* Allow param names to contain dashes ([#8015](http://projects.theforeman.org/issues/8015))
* Add Catalan language ([#14947](http://projects.theforeman.org/issues/14947))
* Add support for Gemfile.local.rb ([#14466](http://projects.theforeman.org/issues/14466))
* Introduced log format setting ([#14591](http://projects.theforeman.org/issues/14591))
* Add pagination info when incomplete data are received (http://projects.theforeman.org/issues/14530)
* Array is merged across YAML settings ([#14590](http://projects.theforeman.org/issues/14590))
* Now hammer recognizes when to create defaults file correctly ([#14311](http://projects.theforeman.org/issues/14311))
* Enable json for key=value parameters ([#12869](http://projects.theforeman.org/issues/12869))
* Fix coded options for apipie 0.3.6 ([#13960](http://projects.theforeman.org/issues/13960))

### 0.6.0 (2016-02-25)
* Enable vertical formatting for lists ([#13874](http://projects.theforeman.org/issues/13874))
* Support for command testing moved to core ([#4118](http://projects.theforeman.org/issues/4118))
* Remove psych require from Gemfile ([#12797](http://projects.theforeman.org/issues/12797))
* Configuration doc on how to enable a plugin ([#13438](http://projects.theforeman.org/issues/13438))

### 0.5.1 (2015-12-15)
* Minor release to fix wrongly packaged gem

### 0.5.0 (2015-12-14)
* Added defaults options in hammer cli ([#8015](http://projects.theforeman.org/issues/8015))
* Do not display hidden options in --help ([#12693](http://projects.theforeman.org/issues/12693))
* Refs #10564 - interpolate option in i18n string correctly ([#10564](http://projects.theforeman.org/issues/10564))
* Json and yaml formatting for messages ([#11355](http://projects.theforeman.org/issues/11355))

### 0.4.0 (2015-09-21)
* Pull in the downstream translations ([#11184](http://projects.theforeman.org/issues/11184))
* Abort when custom config file is not found ([#11158](http://projects.theforeman.org/issues/11158))
* Add filtering of the logs ([#7534](http://projects.theforeman.org/issues/7534))
* Bump required apipie-bindings version ([#11452](http://projects.theforeman.org/issues/11452))
* Prevents hammer from reading ./config file ([#11439](http://projects.theforeman.org/issues/11439))
* Drop Ruby 1.8 support ([#11280](http://projects.theforeman.org/issues/11280))

### 0.3.0 (2015-07-29)
* Add normalizer converting id parameter values to numbers ([#11137](http://projects.theforeman.org/issues/11137))
* Set Enum normalizer on enumerated values ([#11033](http://projects.theforeman.org/issues/11033))
* Add missing options to preparser ([#10902](http://projects.theforeman.org/issues/10902))
* Added support for deprecated options ([#10564](http://projects.theforeman.org/issues/10564))


### 0.2.0 (2015-04-23)
* Rubygem locale pined to version >= 2.0.6 ([#10154](http://projects.theforeman.org/issues/10154))
* Restricted logging version as in 2.0.0 ruby 1.8.7 support was dropped
* Allow :hide_blank for labels ([#9925](http://projects.theforeman.org/issues/9925))
* Only initialise text domains that have files in the dir ([#9648](http://projects.theforeman.org/issues/9648))
* Version fails with error ([#9742](http://projects.theforeman.org/issues/9742))
* Ignore spaces in key value formatting ([#9721](http://projects.theforeman.org/issues/9721))
* Fixing warning of already initialized constant ([#9714](http://projects.theforeman.org/issues/9714))
* Highline pinned to < 1.7 ([#9507](http://projects.theforeman.org/issues/9507))
* Docs - link to slides from cfgmgmt camp
* Update to gettext 3.x, unpin locale ([#8980](http://projects.theforeman.org/issues/8980))
* Docs - link to available plugins listed on external wiki.


### 0.1.4 (2014-12-10)
* hammer-cli CSV formatter doesn't properly format values with custom formatters, moving to correct implementation ([#8569](http://projects.theforeman.org/issues/8569))
* added support for dependeces among modules ([#7566](http://projects.theforeman.org/issues/7566))
* Add option forcing apipie cache reload ([#8430](http://projects.theforeman.org/issues/8430))
* Missing search options error message ([#5556](http://projects.theforeman.org/issues/5556))
* Adds YAML and JSON output adapters (BZ1122650) ([#6754](http://projects.theforeman.org/issues/6754))
* Credentials interface definition moved to ApipieBindings ([#7408](http://projects.theforeman.org/issues/7408))
* Catching apipie-bindings' MissingArgumentsError ([#6820](http://projects.theforeman.org/issues/6820))
* Prints table headers when no data ([#7001](http://projects.theforeman.org/issues/7001))
* i18n - add zh_CN language
* i18n - add de, it, pt_BR, zh_TW, ru, ja, ko languages
* Readable help for long options ([#5417](http://projects.theforeman.org/issues/5417))
* Give usage information for boolean types ([#7284](http://projects.theforeman.org/issues/7284))
* Minor updates in devel docs ([#5052](http://projects.theforeman.org/issues/5052))
* Avoid locale domain name conflict ([#7262](http://projects.theforeman.org/issues/7262))


### 0.1.3
* Fixed detection of list type options  ([#7144](http://projects.theforeman.org/issues/7144))
* Key-value normalizer accepts arrays ([#7133](http://projects.theforeman.org/issues/7133))
* Make the zanata settings consistent ([#7111](http://projects.theforeman.org/issues/7111))
* Adding system locale domain ([#7083](http://projects.theforeman.org/issues/7083))


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
