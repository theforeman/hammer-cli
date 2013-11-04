require File.join(File.dirname(__FILE__), '../test_helper')

# require 'hammer_cli/options/option_definition'

describe HammerCLI::Options::OptionDefinition do

  class FakeFormatter < HammerCLI::Options::Normalizers::AbstractNormalizer
    def format(val)
      ">>>#{val}<<<"
    end
  end

  class TestOptionFormattersCmd < HammerCLI::AbstractCommand
    option "--test-format", "TEST_FORMAT", "Test option with a formatter",
      :format => FakeFormatter.new,
      :default => "A"
  end

  describe "formatters" do

    it "should use formatter to format a default value" do
      opt = TestOptionFormattersCmd.find_option("--test-format")

      opt_instance = opt.of(TestOptionFormattersCmd.new([]))
      opt_instance.read.must_equal '>>>A<<<'
    end

    it "should use formatter as a conversion block" do
      opt = TestOptionFormattersCmd.find_option("--test-format")

      opt_instance = opt.of(TestOptionFormattersCmd.new([]))
      opt_instance.write('B')
      opt_instance.read.must_equal '>>>B<<<'
    end
  end

end

