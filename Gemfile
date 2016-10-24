source "https://rubygems.org"

gemspec

gem 'gettext', '>= 3.1.3', '< 4.0.0'
if RUBY_VERSION < '2.1.0'
  gem 'clamp', '< 1.1.0'
  gem 'fast_gettext', '< 1.2.0'
end


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
['Gemfile.local.rb', 'Gemfile.local'].map do |file_name|
  local_gemfile = File.join(File.dirname(__FILE__), file_name)
  self.instance_eval(Bundler.read_file(local_gemfile)) if File.exist?(local_gemfile)
end
