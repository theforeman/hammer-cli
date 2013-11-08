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
      # clamp api changed in 0.6.2
      if opt_instance.respond_to? :write 
        opt_instance.write('B')
      else
        opt_instance.take('B')
      end
      opt_instance.read.must_equal '>>>B<<<'
    end
  end

end

