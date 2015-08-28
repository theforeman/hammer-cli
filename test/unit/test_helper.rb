require 'simplecov'
require 'pathname'

SimpleCov.use_merging true
SimpleCov.start do
  command_name 'MiniTest'
  add_filter 'test'
end
SimpleCov.root Pathname.new(File.dirname(__FILE__) + "../../../")

require 'minitest/autorun'
require 'minitest/spec'
require "minitest-spec-context"
require "mocha/setup"

require 'hammer_cli'
require 'hammer_cli/logger'

Logging.logger.root.appenders = Logging::Appenders['__test__'] || Logging::Appenders::StringIo.new('__test__')

