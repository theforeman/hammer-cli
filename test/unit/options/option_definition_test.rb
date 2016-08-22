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
    option "--test-context", "CONTEXT", "Option saved into context",
      :context_target => :test_option
  end

  class TestDeprecatedOptionCmd < HammerCLI::AbstractCommand
    option ["--test-option", "--deprecated"], "TEST_OPTION", "Test option",
      :context_target => :test_option,
      :deprecated => { "--deprecated" => "Use --test-option instead" }
    option "--another-deprecated", "OLD_OPTION", "Test old option",
      :context_target => :old_option,
      :deprecated => "It is going to be removed"
  end

  def opt_with_deprecation(deprecation)
    HammerCLI::Options::OptionDefinition.new(["--test-option", "--better-switch"], "TEST_OPTION", "Test option", :deprecated => deprecation)
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

  describe "deprecated options" do
    it "prints deprecation warning" do
      context = {}
      cmd = TestDeprecatedOptionCmd.new("", context)

      out, err = capture_io { cmd.run(["--another-deprecated=VALUE"]) }
      err.must_match /Warning: Option --another-deprecated is deprecated. It is going to be removed/
      context[:old_option].must_equal "VALUE"
    end

    it "prints deprecation warning (extended version)" do
      context = {}
      cmd = TestDeprecatedOptionCmd.new("", context)

      out, err = capture_io { cmd.run(["--deprecated=VALUE"]) }
      err.must_match /Warning: Option --deprecated is deprecated. Use --test-option instead/
      context[:test_option].must_equal "VALUE"
    end

    it 'shows depracated message in help' do
      opt = opt_with_deprecation("Use --better-switch instead")
      opt.description.must_equal "Test option (Deprecated: Use --better-switch instead)"
    end

    it 'shows flag specific depracated message in help' do
      opt = opt_with_deprecation('--test-option' => "Use --better-switch instead")
      opt.description.must_equal "Test option (--test-option is deprecated: Use --better-switch instead)"
    end

    it 'shows multiple flag specific depracated messages in help' do
      opt = opt_with_deprecation('--test-option' => "Use --better-switch instead", '--test-option2' => 'This is deprecated too')
      opt.description.must_equal "Test option (--test-option is deprecated: Use --better-switch instead, --test-option2 is deprecated: This is deprecated too)"
    end
  end

  describe "context" do
    it "should save option to context" do
      context = {}
      cmd = TestOptionFormattersCmd.new("", context)
      cmd.run(["--test-context=VALUE"])
      context[:test_option].must_equal "VALUE"
    end
  end
end

