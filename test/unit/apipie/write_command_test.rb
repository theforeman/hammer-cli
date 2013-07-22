require_relative '../test_helper'
require_relative 'fake_api'

describe HammerCLI::Apipie::WriteCommand do

  let(:cmd) { HammerCLI::Apipie::WriteCommand.new("") }
  let(:cmd_run) { cmd.run([]) }

  it "should raise exception when no action is defined" do
    proc { cmd_run }.must_raise RuntimeError
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

