require File.join(File.dirname(__FILE__), 'test_helper')
require 'tempfile'


describe HammerCLI::OptionBuilderContainer do

  let(:options) {
    [
      HammerCLI::Options::OptionDefinition.new(["--test"], "TEST", "test"),
      HammerCLI::Options::OptionDefinition.new(["--test2"], "TEST2", "test2")
    ]
  }
  let(:container) { HammerCLI::OptionBuilderContainer.new }

  it "collects options from contained builders" do
    builder = Object.new
    builder.stubs(:build).returns(options)

    container.builders = [builder, builder]
    container.build.must_equal options+options
  end

  it "passes build parameters from contained builders" do
    params = {:param => :value}
    builder = Object.new
    builder.expects(:build).with(params).returns(options)

    container.builders = [builder]
    container.build(params)
  end

end

