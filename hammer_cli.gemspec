# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hammer_cli/version"

Gem::Specification.new do |s|

  s.name          = "hammer_cli"
  s.version       = HammerCLI.version.dup
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Martin Bačovský", "Tomáš Strachota"]
  s.email         = "mbacovsk@redhat.com"
  s.homepage      = "http://github.com/theforeman/hammer-cli"
  s.license       = "GPL-3"

  s.summary       = %q{Universal command-line interface}
  s.description   = <<EOF
Hammer cli provides universal extendable CLI interface for ruby apps
EOF

  s.files            = Dir['{lib,test,bin,doc,config,locale}/**/*', 'LICENSE', 'README*', 'hammer_cli_complete']
  s.test_files       = Dir['test/**/*']
  s.extra_rdoc_files = Dir['{doc,config}/**/*', 'README*']
  s.require_paths = ["lib"]
  s.executables = ['hammer']

  s.add_dependency 'clamp', '>= 1.0.0'
  s.add_dependency 'rest-client', '< 1.7.0' #higher versions are not ruby 1.8 compatible
  s.add_dependency 'logging', '< 2.0.0' #higher versions are not ruby 1.8 compatible
  s.add_dependency 'awesome_print'
  s.add_dependency 'table_print'
  s.add_dependency 'highline', '< 1.7.0' #higher versions are not ruby 1.8 compatible
  s.add_dependency 'fast_gettext'
  s.add_dependency 'locale', '>= 2.0.6'

  # required for ruby < 1.9.0:
  s.add_dependency 'json'
  s.add_dependency 'rb-readline'           #original readline is missing method 'line_buffer' in 1.8
  s.add_dependency 'fastercsv'             #fastercsv is default for ruby >=1.9 but it's missing in 1.8.X
  s.add_dependency 'mime-types', '~> 1.0'  #newer versions of mime-types are not 1.8 compatible
  s.add_dependency 'apipie-bindings', '~> 0.0.10'

end
