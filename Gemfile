source "https://rubygems.org"

gemspec

gem 'gettext', '>= 3.1.3', '< 4.0.0'
gem 'psych' # requiring psych to workaround issues with bundler 1.11.0, see https://github.com/bundler/bundler/issues/4149

group :test do
  gem 'rake', '~> 10.1.0'
  gem 'thor'
  gem 'minitest', '4.7.4'
  gem 'minitest-spec-context'
  gem 'simplecov'
  gem 'mocha'
  gem 'ci_reporter', '>= 1.6.3', "< 2.0.0", :require => false
end

# load local gemfile
local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
self.instance_eval(Bundler.read_file(local_gemfile)) if File.exist?(local_gemfile)
