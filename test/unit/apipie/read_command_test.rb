require File.join(File.dirname(__FILE__), '../test_helper')


describe HammerCLI::Apipie::ReadCommand do

  class TestReadCommand < HammerCLI::Apipie::ReadCommand
    def self.resource_config
      { :apidoc_cache_dir => 'test/unit/fixtures/apipie', :apidoc_cache_name => 'architectures' }
    end
  end

  let(:cmd_class) { TestReadCommand.dup }
  let(:cmd) { cmd_class.new("", { :adapter => :silent, :interactive => false }) }
  let(:cmd_run) { cmd.run([]) }

  it "should raise exception when no action is defined" do
    cmd.stubs(:handle_exception).returns(HammerCLI::EX_SOFTWARE)
    cmd_run.must_equal HammerCLI::EX_SOFTWARE
  end

  context "resource defined" do

    before :each do
      HammerCLI::Connection.drop_all
      ApipieBindings::API.any_instance.stubs(:call).returns([])
      cmd_class.resource :architectures, :index
    end

    it "should perform a call to api when resource is defined" do
      cmd_run.must_equal 0
    end

  end


end

