require File.join(File.dirname(__FILE__), 'test_helper')
describe HammerCLI::Defaults do

  let(:filepath) { File.join(File.dirname(__FILE__), '/fixtures/defaults/defaults.yml') }

  before(:all) do
    settings = YAML::load(File.open(filepath))

    @defaults = HammerCLI::Defaults.new(settings[:defaults], filepath)
    @defaults.stubs(:write_to_file).returns true
  end

  describe '#add_defaults_to_conf' do
    it "Should add a default param to defaults file, without a provider" do
      defaults_result = @defaults.add_defaults_to_conf({"organization_id"=> 3}, nil)
      assert_equal 3, defaults_result[:defaults][:organization_id][:value]
    end

    it "Should update dashed default when underscored default is set" do
      defaults_result = @defaults.add_defaults_to_conf({"location-id"=> 3}, nil)
      assert_equal 3, defaults_result[:defaults][:'location-id'][:value]
      assert_equal nil, defaults_result[:defaults][:location_id]
    end

    context "dashed" do
      let(:filepath) { File.join(File.dirname(__FILE__), '/fixtures/defaults/defaults_dashed.yml') }
      it "Should update underscored default when dashed default is set" do
        defaults_result = @defaults.add_defaults_to_conf({"location_id"=> 3}, nil)
        assert_equal 3, defaults_result[:defaults][:location_id][:value]
        assert_equal nil, defaults_result[:defaults][:'location-id']
      end
    end

    it "Should add a default param to defaults file, with provider" do
      defaults_result = @defaults.add_defaults_to_conf({"location_id"=>nil}, :foreman)
      assert_equal :foreman, defaults_result[:defaults][:location_id][:provider]
    end
  end

  describe '#delete_default_from_conf' do
    it "Should remove default param from defaults file" do
      defaults_result = @defaults.delete_default_from_conf(:organization_id)
      assert_nil defaults_result[:defaults][:organization_id]
    end

    it "Should remove dashed default param from defaults file" do
      defaults_result = @defaults.delete_default_from_conf(:"organization-id")
      assert_nil defaults_result[:defaults][:organization_id]
    end

    context "dashed" do
      let(:filepath) { File.join(File.dirname(__FILE__), '/fixtures/defaults/defaults_dashed.yml') }
      it "Should remove default param from defaults file" do
        defaults_result = @defaults.delete_default_from_conf(:organization_id)
        assert_nil defaults_result[:defaults][:'organization-id']
      end

      it "Should remove dashed default param from defaults file" do
        defaults_result = @defaults.delete_default_from_conf(:"organization-id")
        assert_nil defaults_result[:defaults][:'organization-id']
      end
    end
  end

  describe '#defaults_set' do
    it "should check if the defaults is set" do
      assert_equal true, @defaults.defaults_set?("location_id")
    end
  end


  describe '#get_defaults' do
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

    context 'dashed params' do
      let(:filepath) { File.join(File.dirname(__FILE__), '/fixtures/defaults/defaults_dashed.yml') }

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
  end

  it "should return empty defaults when the settings file is not present" do
    defaults = HammerCLI::Defaults.new(nil, filepath)
    assert_equal({}, defaults.defaults_settings)
  end

end
