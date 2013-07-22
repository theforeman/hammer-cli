require 'simplecov'

SimpleCov.use_merging true
SimpleCov.filters = []
SimpleCov.start do
  command_name 'MiniTest'

  add_filter "vendor"
  add_filter "test"
  add_filter "opt"
end
SimpleCov.root Pathname.new(File.dirname(__FILE__) + "../../../")


require 'minitest/autorun'
require 'minitest/spec'
require "minitest-spec-context"
require "mocha/setup"

require 'hammer_cli'

