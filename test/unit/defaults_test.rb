require File.join(File.dirname(__FILE__), 'test_helper')
describe HammerCLI::Defaults do

  FILEPATH = File.join(File.dirname(__FILE__), '/fixtures/defaults/defaults.yml')

  before(:all) do
    settings = YAML::load(File.open(FILEPATH))

    @defaults = HammerCLI::Defaults.new(settings[:defaults], FILEPATH)
    @defaults.stubs(:write_to_file).returns true
  end

  it "Should add a default param to defaults file, without a provider" do
    defaults_result = @defaults.add_defaults_to_conf({"organization_id"=> 3}, nil)
    assert_equal 3, defaults_result[:defaults][:organization_id][:value]
  end

  it "Should add a default param to defaults file, with provider" do
    defaults_result = @defaults.add_defaults_to_conf({"location_id"=>nil}, :foreman)
    assert_equal :foreman, defaults_result[:defaults][:location_id][:provider]
  end

  it "Should remove default param from defaults file" do
    defaults_result = @defaults.delete_default_from_conf(:organization_id)
    assert_nil defaults_result[:defaults][:organization_id]
  end

  it "should get the default param, without provider" do
    assert_equal 2, @defaults.get_defaults("location_id")
  end

  it "should get the default param, with provider" do
    fake_provider = mock()
    fake_provider.stubs(:provider_name).returns(:foreman)
    fake_provider.expects(:get_defaults).with(:organization_id).returns(3)
    @defaults.register_provider(fake_provider)
    assert_equal 3, @defaults.get_defaults("organization_id")
  end

end
