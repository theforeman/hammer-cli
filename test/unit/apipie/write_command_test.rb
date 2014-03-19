require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLI::Apipie::WriteCommand do

  class TestWriteCommand < HammerCLI::Apipie::WriteCommand
    def self.resource_config
      { :apidoc_cache_dir => 'test/unit/fixtures/apipie', :apidoc_cache_name => 'architectures' }
    end
  end

  let(:cmd) { TestWriteCommand.new("") }
  let(:cmd_run) { cmd.run([]) }

  it "should raise exception when no action is defined" do
    cmd.stubs(:handle_exception).returns(HammerCLI::EX_SOFTWARE)
    cmd_run.must_equal HammerCLI::EX_SOFTWARE
  end

  context "resource defined" do

    before :each do
      HammerCLI::Connection.drop_all
      ApipieBindings::API.any_instance.stubs(:call).returns([])
      cmd.class.resource :architectures, :index
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

