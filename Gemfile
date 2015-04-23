source "https://rubygems.org"

gemspec

if RUBY_VERSION >= '1.9'
  # for generating i18n files, gettext > 3.0 dropped ruby 1.8 support
  gem 'gettext', '>= 3.1.3', '< 4.0.0'
end

group :test do
  gem 'rake', '~> 10.1.0'
  gem 'thor'
  gem 'minitest', '4.7.4'
  gem 'minitest-spec-context'
  gem 'simplecov', '< 0.9.0' # 0.9.0 is not compatible with Ruby 1.8.x
  gem 'mocha'
  gem 'ci_reporter', '>= 1.6.3', "< 2.0.0", :require => false
end

# load local gemfile
local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
self.instance_eval(Bundler.read_file(local_gemfile)) if File.exist?(local_gemfile)
