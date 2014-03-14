source "http://rubygems.org"

gemspec

# for generating i18n files, gettext > 3.0 dropped ruby 1.8 support
gem 'gettext', '~> 2.0'

group :test do
  gem 'rake'
  gem 'thor'
  gem 'minitest', '4.7.4'
  gem 'minitest-spec-context'
  gem 'simplecov'
  gem 'mocha'
  gem 'ci_reporter'
end

# load local gemfile
local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
self.instance_eval(Bundler.read_file(local_gemfile)) if File.exist?(local_gemfile)
