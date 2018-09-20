require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLI::MainCommand do

  describe "loading context" do

    let(:context) { {} }
    let(:cmd) { HammerCLI::MainCommand.new("", context) }

    before :each do
      cmd.stubs(:execute).returns(1)
    end

    describe "username" do

      it "should prioritize parameter" do
        cmd.run(["-uuser"])
        context[:username].must_equal "user"
      end

      it "should prioritize parameter 2" do
        cmd.run([])
        context[:username].must_equal nil
      end

    end


    describe "password" do

      it "should prioritize parameter" do
        cmd.run(["-ppassword"])
        context[:password].must_equal "password"
      end

      it "should prioritize parameter" do
        cmd.run([])
        context[:password].must_equal nil
      end

    end


    describe 'verbose' do
      it 'stores verbosity level into context' do
        cmd.run(['-v'])
        context[:verbosity].must_equal HammerCLI::V_VERBOSE
        cmd.run(['--no-verbose'])
        context[:verbosity].must_equal HammerCLI::V_UNIX
        cmd.run(['--quiet'])
        context[:verbosity].must_equal HammerCLI::V_QUIET
      end
    end
  end
end
