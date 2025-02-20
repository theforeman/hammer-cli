# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hammer_cli/version"

Gem::Specification.new do |s|

  s.name          = "hammer_cli"
  s.version       = HammerCLI.version.dup
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Martin Bačovský", "Tomáš Strachota"]
  s.email         = "mbacovsk@redhat.com"
  s.homepage      = "https://github.com/theforeman/hammer-cli"
  s.license       = "GPL-3.0-only"

  s.summary       = %q{Universal command-line interface}
  s.description   = <<EOF
Hammer cli provides universal extendable CLI interface for ruby apps
EOF

  locales = Dir['locale/*'].select { |f| File.directory?(f) }
  s.files = Dir['{lib,test,bin,doc,config}/**/*', 'LICENSE', 'README*'] +
    locales.map { |loc| "#{loc}/LC_MESSAGES/hammer-cli.mo" } +
    ['locale/Makefile.def', 'man/hammer.1.gz']

  s.test_files       = Dir['test/**/*']
  s.extra_rdoc_files = Dir['{doc,config}/**/*', 'README*']
  s.require_paths = ["lib"]
  s.executables = ['hammer', 'hammer-complete']

  s.required_ruby_version = '>= 2.7'

  s.add_dependency 'amazing_print'
  s.add_dependency 'apipie-bindings', '>= 0.7.0'
  s.add_dependency 'base64' # oauth requires this but doesn't depend on it
  s.add_dependency 'clamp', '>= 1.3.1', '< 2.0.0'
  s.add_dependency 'csv'
  s.add_dependency 'fast_gettext'
  s.add_dependency 'highline'
  s.add_dependency 'locale', '>= 2.0.6'
  s.add_dependency 'logging'
  s.add_dependency 'unicode-display_width'
end
