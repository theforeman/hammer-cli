require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLI::MainCommand do

  describe "loading context" do

    let(:context) { {} }
    let(:cmd) { HammerCLI::MainCommand.new("", context) }

    before :each do
      cmd.stubs(:execute).returns(1)
      HammerCLI::Settings.clear
      HammerCLI::Settings.load({
        :username => :settings_username,
        :password => :settings_password
      })
      ENV['HAMMER_USERNAME'] = nil
      ENV['HAMMER_PASSWORD'] = nil
    end

    describe "username" do

      it "should prioritize parameter" do
        cmd.run(["-uuser"])
        context[:username].must_equal "user"
      end

      it "should be taken from env variable if the parameter was not passed" do
        ENV['HAMMER_USERNAME'] = 'env_username'
        cmd.run([])
        context[:username].must_equal 'env_username'
      end

      it "should be loaded from settings if the env variable was not set" do
        cmd.run([])
        context[:username].must_equal :settings_username
      end

    end


    describe "password" do

      it "should prioritize parameter" do
        cmd.run(["-ppassword"])
        context[:password].must_equal "password"
      end

      it "should be taken from env variable if the parameter was not passed" do
        ENV['HAMMER_PASSWORD'] = 'env_password'
        cmd.run([])
        context[:password].must_equal 'env_password'
      end

      it "should be loaded from settings if the env variable was not set" do
        cmd.run([])
        context[:password].must_equal :settings_password
      end

    end


  end

end

