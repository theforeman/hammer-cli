Writing your own Hammer plugin
------------------------------

In this tutorial we will create a simple hello world plugin.

Hammer plugins are nothing but gems. Details on how to build a gem can be found for example at [rubygems.org](http://guides.rubygems.org/make-your-own-gem/).
In the first part of this tutorial we will briefly guide you through the process of creating a very simple gem. First of all you will need the rubygems package installed on your system.

Create the basic gem structure in a project subdirectory of your choice:
```
$ cd ./my_first_hammer_plugin/
$ touch Gemfile
$ touch hammer_cli_hello.gemspec
$ mkdir -p lib/hammer_cli_hello
$ touch lib/hammer_cli_hello.rb
$ touch lib/hammer_cli_hello/version.rb
```

Example `Gemfile`:
```ruby
source "https://rubygems.org"

gemspec
```

Example `hammer_cli_hello.gemspec` file:
```ruby
$:.unshift File.expand_path("../lib", __FILE__)
require "hammer_cli_hello/version"

Gem::Specification.new do |s|

  s.name = "hammer_cli_hello"
  s.authors = ["Me"]
  s.version = HammerCLIHello.version.dup
  s.platform = Gem::Platform::RUBY
  s.summary = %q{Hello world commands for Hammer}

  s.files = Dir['lib/**/*.rb']
  s.require_paths = ["lib"]

  s.add_dependency 'hammer_cli', '>= 0.0.6'
end
```
More details about the gemspec structure is again at [rubygems.org](http://guides.rubygems.org/specification-reference/).

We'll have to specify the plugin version in `lib/hammer_cli_hello/version.rb`:
```ruby
module HammerCLIHello
  def self.version
    @version ||= Gem::Version.new '0.0.1'
  end
end
```

This should be enough for creating a minimalist gem. Let's build and install it.
```
$ gem build ./hammer_cli_hello.gemspec
$ gem install hammer_cli_hello-0.0.1.gem
```

Place your module's config file into `~/.hammer/cli.modules.d/hello_world.yml`.
```yaml
:hello:
  :enable_module: true
```


Verify the installation by running:
```
$ hammer -v > /dev/null
```

You should see a message saying that your module was loaded (second line in the sample output).
```
[ INFO 2013-10-16 11:19:06 Init] Initialization of Hammer CLI (0.1.0) has started...
[ INFO 2013-10-16 11:19:06 Init] Extension module hammer_cli_hello loaded
[ INFO 2013-10-16 11:19:06 Init] Configuration from the file /root/.hammer/cli_config.yml has been loaded
[ INFO 2013-10-16 11:19:06 Init] Configuration from the file /root/.hammer/cli.modiles.d/hello.yml has been loaded
[ INFO 2013-10-16 11:19:06 HammerCLI::MainCommand] Called with options: {"verbose"=>true}
```

Done. Your first hammer plugin is installed. Unfortunately it does not contain any commands yet. So let's start adding some to finally enjoy real results.

Optionally you can add a Rakefile and build and install the gem with `rake install`
```ruby
# ./Rakefile
require 'bundler/gem_tasks'
```

