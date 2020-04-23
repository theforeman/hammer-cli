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

  let(:resource) {api.resource(:documented)}
  let(:action) {resource.action(:index)}
  let(:builder) { HammerCLI::Apipie::OptionBuilder.new(resource, action) }
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

    it "should build option with default family" do
      options[0].family.wont_be_nil
    end

    it "should build parent option within default family" do
      options[0].child?.must_equal false
    end
  end


  context "required options" do

    let(:action) {resource.action(:create)}
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
    let(:action) {resource.action(:create)}

    it "should create options for all parameters except the hash" do
      options.map(&:attribute_name).sort.must_equal HammerCLI.option_accessor_name("array_param", "name", "provider")
    end

    it "should name the options correctly" do
      options.map(&:attribute_name).sort.must_equal HammerCLI.option_accessor_name("array_param", "name", "provider")
    end
  end

  context "setting correct normalizers" do
    let(:action) {resource.action(:typed_params)}

    it "should set array normalizer" do
      array_option = options.find {|o| o.attribute_name == HammerCLI.option_accessor_name("array_param") }
      array_option.value_formatter.class.must_equal HammerCLI::Options::Normalizers::List
    end

    it "should set boolean normalizer" do
      boolean_option = options.find {|o| o.attribute_name == HammerCLI.option_accessor_name("boolean_param") }
      boolean_option.value_formatter.class.must_equal HammerCLI::Options::Normalizers::Bool
    end

    it "should set enum normalizer" do
      enum_option = options.find {|o| o.attribute_name == HammerCLI.option_accessor_name("enum_param") }
      enum_option.value_formatter.class.must_equal HammerCLI::Options::Normalizers::Enum
      enum_option.value_formatter.allowed_values.sort.must_equal ["one", "two", "three"].sort
    end

    it "should set enum normalizer and handle coded values" do
      enum_option = options.find {|o| o.attribute_name == HammerCLI.option_accessor_name("coded_enum_param") }
      enum_option.value_formatter.class.must_equal HammerCLI::Options::Normalizers::Enum
      enum_option.value_formatter.allowed_values.sort.must_equal ["array", "boolean", "hash", "integer", "json", "real", "string", "yaml"].sort
    end

    it "should set list normalizer for array of nested elements" do
      array_option = options.find {|o| o.attribute_name == HammerCLI.option_accessor_name("nested_elements_param") }
      array_option.value_formatter.class.must_equal HammerCLI::Options::Normalizers::List
    end

    it "should set number normalizer" do
      numeric_option = options.find {|o| o.attribute_name == HammerCLI.option_accessor_name("numeric_param") }
      numeric_option.value_formatter.class.must_equal HammerCLI::Options::Normalizers::Number
    end

    it "should set number normalizer for integer" do
      integer_option = options.find {|o| o.attribute_name == HammerCLI.option_accessor_name("integer_param") }
      integer_option.value_formatter.class.must_equal HammerCLI::Options::Normalizers::Number
    end

  end


  context "filtering options" do
    let(:action) {resource.action(:create)}

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
    let(:action) {resource.action(:action_with_ids)}
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

  context "setting referenced resources" do
    let(:action) {resource.action(:action_with_ids)}

    it "sets referenced resources" do
      options.map(&:referenced_resource).map(&:to_s).sort.must_equal ["", "compute_resource", "organization", "organization"]
    end
  end

end
