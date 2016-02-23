require File.join(File.dirname(__FILE__), '../test_helper')

require 'hammer_cli/testing/output_matchers'
require 'hammer_cli/testing/command_assertions'
require 'hammer_cli/testing/data_helpers'

include HammerCLI::Testing::OutputMatchers
include HammerCLI::Testing::CommandAssertions
include HammerCLI::Testing::DataHelpers
