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

  s.summary       = %q{Universal command-line interface}
  s.description   = <<EOF
Hammer cli provides universal extendable CLI interface for ruby apps
EOF

  # s.files         = `git ls-files`.split("\n")
  s.files = Dir['lib/**/*.rb'] + Dir['bin/*']
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.test_files = Dir.glob('test/tc_*.rb')
  s.require_paths = ["lib"]
  s.executables = ['hammer']

  s.add_dependency 'clamp'
  s.add_dependency 'terminal-table'
  s.add_dependency 'rest-client'
  s.add_dependency 'logging'
  s.add_dependency 'awesome_print'

end
