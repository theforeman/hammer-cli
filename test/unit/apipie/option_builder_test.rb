require File.join(File.dirname(__FILE__), '../test_helper')


describe HammerCLI::OptionBuilderContainer do

end

describe HammerCLI::Apipie::OptionBuilder do

  let(:api) do
    ApipieBindings::API.new({
      :apidoc_cache_dir => 'test/unit/fixtures/apipie',
      :apidoc_cache_name => 'documented'
    })
  end

  before :each do
    HammerCLI::I18n.clear
  end

  let(:action) {api.resource(:documented).action(:index)}
  let(:builder) { HammerCLI::Apipie::OptionBuilder.new(action) }
  let(:builder_options) { {} }
  let(:options) { builder.build(builder_options) }

  context "with one simple param" do

    it "should create an option for the parameter" do
      options.length.must_equal 1
    end

    it "should set correct switch" do
      options[0].switches.must_be :include?, '--se-arch-val-ue'
    end

    it "should set correct attribute name" do
      options[0].attribute_name.must_equal HammerCLI.option_accessor_name('se_arch_val_ue')
    end

    it "should set description with html tags stripped" do
      options[0].description.must_equal 'filter results'
    end
  end


  context "required options" do

    let(:action) {api.resource(:documented).action(:create)}
    let(:required_options) { builder.build.reject{|opt| !opt.required?} }

    it "should set required flag for the required options" do
      required_options.map(&:attribute_name).sort.must_equal [HammerCLI.option_accessor_name("array_param")]
    end

    it "should not require any option when requirements are disabled" do
      builder.require_options = false
      required_options.map(&:attribute_name).sort.must_equal []
    end
  end


  context "with hash params" do
    let(:action) {api.resource(:documented).action(:create)}

    it "should create options for all parameters except the hash" do
      options.map(&:attribute_name).sort.must_equal HammerCLI.option_accessor_name("array_param", "name", "provider")
    end

    it "should name the options correctly" do
      options.map(&:attribute_name).sort.must_equal HammerCLI.option_accessor_name("array_param", "name", "provider")
    end
  end

  context "setting correct normalizers" do
    let(:action) {api.resource(:documented).action(:create)}

    it "should set array normalizer" do
      array_option = options.find {|o| o.attribute_name == HammerCLI.option_accessor_name("array_param") }
      array_option.value_formatter.class.must_equal HammerCLI::Options::Normalizers::List
    end

  end


  context "filtering options" do
    let(:action) {api.resource(:documented).action(:create)}

    it "should skip filtered options" do
      builder_options[:without] = ["provider", "name"]
      options.map(&:attribute_name).sort.must_equal [HammerCLI.option_accessor_name("array_param")]
    end

    it "should skip filtered options defined as symbols" do
      builder_options[:without] = [:provider, :name]
      options.map(&:attribute_name).sort.must_equal [HammerCLI.option_accessor_name("array_param")]
    end

    it "should skip single filtered option in array" do
      builder_options[:without] = ["provider"]
      options.map(&:attribute_name).sort.must_equal HammerCLI.option_accessor_name("array_param", "name")
    end

    it "should skip single filtered option" do
      builder_options[:without] = "provider"
      options.map(&:attribute_name).sort.must_equal HammerCLI.option_accessor_name("array_param", "name")
    end

  end
end

