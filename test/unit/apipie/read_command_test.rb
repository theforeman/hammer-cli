require File.join(File.dirname(__FILE__), '../test_helper')
require File.join(File.dirname(__FILE__), 'fake_api')


describe HammerCLI::Apipie::ReadCommand do

  let(:cmd_class) { HammerCLI::Apipie::ReadCommand.dup }
  let(:cmd) { cmd_class.new("") }
  let(:cmd_run) { cmd.run([]) }

  before :each do
    cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
  end

  it "should raise exception when no action is defined" do
    proc { cmd_run }.must_raise RuntimeError
  end

  it "should hold instance of output definition" do
    cmd.output_definition.must_be_instance_of HammerCLI::Output::Definition
  end

  context "resource defined" do

    before :each do
      cmd_class.resource FakeApi::Resources::Architecture, "some_action"

      arch = FakeApi::Resources::Architecture.new
      arch.expects(:some_action).returns([])
      FakeApi::Resources::Architecture.stubs(:new).returns(arch)
    end

    it "should perform a call to api when resource is defined" do
      cmd_run.must_equal 0
    end

  end


end

