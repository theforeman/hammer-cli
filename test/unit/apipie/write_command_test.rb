require File.join(File.dirname(__FILE__), '../test_helper')
require File.join(File.dirname(__FILE__), 'fake_api')

describe HammerCLI::Apipie::WriteCommand do


  let(:ctx) { { :interactive => false } }
  let(:cmd) { HammerCLI::Apipie::WriteCommand.new("", ctx) }
  let(:cmd_run) { cmd.run([]) }

  it "should raise exception when no action is defined" do
    cmd.stubs(:handle_exception).returns(HammerCLI::EX_SOFTWARE)
    cmd_run.must_equal HammerCLI::EX_SOFTWARE
  end

  context "resource defined" do

    before :each do
      cmd.class.resource FakeApi::Resources::Architecture, "some_action"

      arch = FakeApi::Resources::Architecture.new
      arch.expects(:some_action).returns([])
      FakeApi::Resources::Architecture.stubs(:new).returns(arch)
    end

    it "should perform a call to api when resource is defined" do
      cmd_run.must_equal 0
    end

    context "output" do
      it "should print success message" do
        cmd.class.success_message "XXX"
        proc { cmd_run }.must_output /.*XXX.*/
      end
    end

  end

end

