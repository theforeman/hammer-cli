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
    let(:optional_options) { builder.build.reject{|opt| opt.required?} }

    it "should set required flag for the required options" do
      required_options.map(&:attribute_name).sort.must_equal [HammerCLI.option_accessor_name("array_param")]
    end

    it "should not require any option when requirements are disabled" do
      builder.require_options = false
      required_options.map(&:attribute_name).sort.must_equal []
    end

    it "should state optional if option is not required" do
      optional_options.each do |o|
        o.help_lhs.include? "optional"
      end
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
    let(:action) {api.resource(:documented).action(:typed_params)}

    it "should set array normalizer" do
      array_option = options.find {|o| o.attribute_name == HammerCLI.option_accessor_name("array_param") }
      array_option.value_formatter.class.must_equal HammerCLI::Options::Normalizers::List
    end

    it "should set boolean normalizer" do
      boolean_option = options.find {|o| o.attribute_name == HammerCLI.option_accessor_name("boolean_param") }
      boolean_option.value_formatter.class.must_equal HammerCLI::Options::Normalizers::Bool
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

  context "aliasing resources" do
    let(:action) {api.resource(:documented).action(:action_with_ids)}
    let(:builder_options) { {:resource_mapping => {:organization => 'company', 'compute_resource' => :compute_provider}} }

    it "renames options" do
      # builder_options[:resource_mapping] = {:organization => 'company', 'compute_resource' => :compute_provider}
      options.map(&:long_switch).sort.must_equal ["--company-id", "--company-ids", "--compute-provider-id", "--name"]
    end

    it "renames option types" do
      # builder_options[:resource_mapping] = {:organization => 'company', 'compute_resource' => :compute_provider}
      options.map(&:type).sort.must_equal ["COMPANY_ID", "COMPANY_IDS", "COMPUTE_PROVIDER_ID", "NAME"]
    end

    it "keeps option accessor the same" do
      # builder_options[:resource_mapping] = {:organization => 'company', 'compute_resource' => :compute_provider}
      options.map(&:attribute_name).sort.must_equal HammerCLI.option_accessor_name("compute_resource_id", "name", "organization_id", "organization_ids")
    end

  end

end

