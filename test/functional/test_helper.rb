require File.join(File.dirname(__FILE__), '../test_helper')

require 'hammer_cli/testing/output_matchers'
require 'hammer_cli/testing/command_assertions'
require 'hammer_cli/testing/data_helpers'

include HammerCLI::Testing::OutputMatchers
include HammerCLI::Testing::CommandAssertions
include HammerCLI::Testing::DataHelpers

def defaults_mock(providers = {})
  defaults_path = File.join(File.dirname(__FILE__), '../unit/fixtures/defaults/defaults.yml')
  settings = load_yaml(defaults_path)

  defaults = HammerCLI::Defaults.new(settings[:defaults], defaults_path)
  defaults.stubs(:write_to_file).returns true
  defaults.stubs(:providers).returns(providers)
  defaults
end
