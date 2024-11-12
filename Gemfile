source "https://rubygems.org"

gemspec

gem 'gettext', '>= 3.1.3', '< 4.0.0'

# FFI 1.17 needs rubygems 3.3.22+, which is Ruby 3.0+ only
gem "ffi", "<1.17" if RUBY_VERSION < '3.0'

group :test do
  gem 'rake'
  gem 'thor'
  gem 'minitest', '~> 5.18'
  gem 'minitest-spec-context'
  gem 'simplecov'
  gem 'mocha'
  gem 'ci_reporter_minitest', '~> 1.0', :require => false
end

# load local gemfile
['Gemfile.local.rb', 'Gemfile.local'].map do |file_name|
  local_gemfile = File.join(File.dirname(__FILE__), file_name)
  self.instance_eval(Bundler.read_file(local_gemfile)) if File.exist?(local_gemfile)
end
