Development Tips
----------------

### Local gem modifications
If you want to modify the gems setup for development needs, create a file `Gemfile.local.rb` in the root of your hammer-cli checkout. You can override the setup from `Gemfile` there. This file is git-ignored so you can easily keep your custom tuning.

Typical usage is for linking plugins from local checkouts:
```ruby
gem 'hammer_cli_foreman', :path => '../hammer-cli-foreman'
```

### Debugging with Pry
[Pry](https://github.com/pry/pry) is a runtime developer console for ruby.
It allows debugging when [Pry Debugger](https://github.com/nixme/pry-debugger) is installed alongside.

For basic usage, add following the lines to your `Gemfile.local.rb`:

```ruby
gem 'pry'
gem 'pry-debugger', :platforms => [:ruby_19]
```

Then add this line at the place where you want the script to break:

```ruby
require 'pry'; binding.pry
```

Pry Debugger supports all expected debugging features.
See [its documentation](https://github.com/nixme/pry-debugger#pry-debugger-) for details.
