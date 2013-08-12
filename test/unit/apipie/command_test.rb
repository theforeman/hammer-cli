require File.join(File.dirname(__FILE__), '../test_helper')
require File.join(File.dirname(__FILE__), 'fake_api')


describe HammerCLI::Apipie::Command do

  let(:cmd_class) { HammerCLI::Apipie::Command.dup }
  let(:cmd) { cmd_class.new("") }

  it "should hold instance of output" do
    cmd.output.must_be_instance_of HammerCLI::Output::Output
  end

  context "setting resources" do

    it "should set resource and action together" do
      cmd_class.resource FakeApi::Resources::Architecture, :index

      cmd.resource.must_be_instance_of FakeApi::Resources::Architecture
      cmd_class.resource.must_equal FakeApi::Resources::Architecture

      cmd.action.must_equal :index
      cmd_class.action.must_equal :index
    end

    it "should set resource alone" do
      cmd_class.resource FakeApi::Resources::Architecture

      cmd.resource.must_be_instance_of FakeApi::Resources::Architecture
      cmd_class.resource.must_equal FakeApi::Resources::Architecture

      cmd.action.must_equal nil
      cmd_class.action.must_equal nil
    end

    it "should set resource and action alone" do
      cmd_class.resource FakeApi::Resources::Architecture
      cmd_class.action :index

      cmd.resource.must_be_instance_of FakeApi::Resources::Architecture
      cmd_class.resource.must_equal FakeApi::Resources::Architecture

      cmd.action.must_equal :index
      cmd_class.action.must_equal :index
    end

  end

  context "apipie generated options" do

    context "with one simple param" do

      let(:option) { cmd_class.declared_options[0] }

      before :each do
        cmd_class.resource FakeApi::Resources::Documented, :index
        cmd_class.apipie_options
      end

      it "should create an option for the parameter" do
        cmd_class.declared_options.length.must_equal 1
      end

      it "should set correct switch" do
        option.switches.must_be :include?, '--se-arch-val-ue'
      end

      it "should set correct attribute name" do
        option.attribute_name.must_equal 'se_arch_val_ue'
      end

      it "should set description with html tags stripped" do
        option.description.must_equal 'filter results'
      end
    end

    context "required options" do
      before :each do
        cmd_class.resource FakeApi::Resources::Documented, :create
        cmd_class.apipie_options
      end

      let(:required_options) { cmd_class.declared_options.reject{|opt| !opt.required?} }

      it "should set required flag for the required options" do
        required_options.map(&:attribute_name).sort.must_equal ["array_param"]
      end
    end

    context "with hash params" do
      before :each do
        cmd_class.resource FakeApi::Resources::Documented, :create
        cmd_class.apipie_options
      end

      it "should create options for all parameters except the hash" do
        cmd_class.declared_options.map(&:attribute_name).sort.must_equal ["array_param", "name", "provider"]
      end

      it "should name the options correctly" do
        cmd_class.declared_options.map(&:attribute_name).sort.must_equal ["array_param", "name", "provider"]
      end
    end

    context "array params" do
      before :each do
        cmd_class.resource FakeApi::Resources::Documented, :create
        cmd_class.apipie_options
      end

      let(:cmd) do
        cmd_class.new("").tap do |cmd|
          cmd.stubs(:execute).returns(0)
        end
      end

      it "should parse comma separated string to array" do
        cmd.run(["--array-param=valA,valB,valC"])
        cmd.array_param.must_equal ['valA', 'valB', 'valC']
      end

      it "should parse string to array of length 1" do
        cmd.run(["--array-param=valA"])
        cmd.array_param.must_equal ['valA']
      end

      it "should parse empty string to empty array" do
        cmd.run(['--array-param='])
        cmd.array_param.must_equal []
      end

    end


    context "filtering options" do
      before :each do
        cmd_class.resource FakeApi::Resources::Documented, :create
      end

      it "should skip filtered options" do
        cmd_class.apipie_options :without => ["provider", "name"]
        cmd_class.declared_options.map(&:attribute_name).sort.must_equal ["array_param"]
      end

      it "should skip single filtered option in array" do
        cmd_class.apipie_options :without => ["provider"]
        cmd_class.declared_options.map(&:attribute_name).sort.must_equal ["array_param", "name"]
      end

      it "should skip single filtered option" do
        cmd_class.apipie_options :without => "provider"
        cmd_class.declared_options.map(&:attribute_name).sort.must_equal ["array_param", "name"]
      end

    end

  end

end

