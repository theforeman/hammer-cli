require File.join(File.dirname(__FILE__), '../test_helper')


describe HammerCLI::Apipie::Command do

  class TestCommand < HammerCLI::Apipie::Command
    def self.resource_config
      { :apidoc_cache_dir => 'test/unit/fixtures/apipie', :apidoc_cache_name => 'architectures' }
    end
  end

  class ParentCommand < TestCommand
    action :show
  end

  class CommandA < TestCommand
    resource :architectures, :index

    class CommandB < ParentCommand
    end
  end

  class CommandC < CommandA
  end

  let(:ctx) { { :adapter => :silent, :interactive => false } }
  let(:cmd_class) { TestCommand.dup }
  let(:cmd) { cmd_class.new("", ctx) }

  before :each do
    HammerCLI::Connection.drop_all
  end

  context "setting identifiers" do

    let(:option_switches) { cmd_class.declared_options.map(&:switches).sort }
    let(:option_attribute_names) { cmd_class.declared_options.map(&:attribute_name).sort }

    class Cmd1 < TestCommand
      identifiers :id, :name, :label
      apipie_options
    end

    class Cmd2 < Cmd1
      identifiers :id
      apipie_options
    end

    it "must not set any option by default" do
      cmd_class.apipie_options
      cmd_class.declared_options.must_equal []
    end

    it "can set option --id" do
      cmd_class.identifiers :id
      cmd_class.apipie_options
      option_switches.must_equal [["--id"]]
      option_attribute_names.must_equal [HammerCLI.option_accessor_name("id")]
    end

    it "can set option --name" do
      cmd_class.identifiers :name
      cmd_class.apipie_options
      option_switches.must_equal [["--name"]]
      option_attribute_names.must_equal [HammerCLI.option_accessor_name("name")]
    end

    it "can set option --label" do
      cmd_class.identifiers :label
      cmd_class.apipie_options
      option_switches.must_equal [["--label"]]
      option_attribute_names.must_equal [HammerCLI.option_accessor_name("label")]
    end

    it "can set multiple identifiers" do
      cmd_class.identifiers :id, :name, :label
      cmd_class.apipie_options
      option_switches.must_equal [["--id"], ["--label"], ["--name"]]
      option_attribute_names.must_equal HammerCLI.option_accessor_name("id", "label", "name")
    end

    it "can change option reader" do
      cmd_class.identifiers :name, :id => :option_id_read_method
      cmd_class.apipie_options
      option_switches.must_equal [["--id"], ["--name"]]
      option_attribute_names.must_equal HammerCLI.option_accessor_name("id_read_method", "name")
    end

    it "can override inentifiers in inherrited classes" do
      Cmd2.new("").class.declared_options.map(&:switches).must_equal [["--id"]]
    end

    context "require identifiers" do

      it "must require one of declared identifiers" do
        cmd_class.identifiers :id, :name
        cmd_class.apipie_options
        cmd.run(["--id=1"]).must_equal HammerCLI::EX_OK
      end

      it "must raise exception when no attribute is passed" do
        cmd_class.identifiers :id, :name
        cmd_class.apipie_options
        cmd.run([]).must_equal HammerCLI::EX_USAGE
      end

      it "must run without error when no identifiers are declared" do
        cmd.run([]).must_equal HammerCLI::EX_OK
      end

    end

  end

  context "setting resources" do

    it "should set resource and action together" do
      cmd_class.resource :architectures, :index

      cmd.resource.name.must_equal :architectures
      cmd_class.resource.name.must_equal :architectures

      cmd.action.must_equal :index
      cmd_class.action.must_equal :index
    end

    it "should set resource alone" do
      cmd_class.resource :architectures

      cmd.resource.name.must_equal :architectures
      cmd_class.resource.name.must_equal :architectures

      cmd.action.must_equal nil
      cmd_class.action.must_equal nil
    end

    it "should set resource and action alone" do
      cmd_class.resource :architectures
      cmd_class.action :index

      cmd.resource.name.must_equal :architectures
      cmd_class.resource.name.must_equal :architectures

      cmd.action.must_equal :index
      cmd_class.action.must_equal :index
    end

    it "inherits action from a parent class" do
      cmd_b = CommandA::CommandB.new("", ctx)
      cmd_b.action.must_equal :show
      cmd_b.class.action.must_equal :show
    end

    it "looks up resource in the class' modules" do
      cmd_b = CommandA::CommandB.new("", ctx)
      cmd_b.resource.name.must_equal :architectures
      cmd_b.class.resource.name.must_equal :architectures
    end

    it "looks up resource in the superclass" do
      cmd_c = CommandC.new("", ctx)
      cmd_c.resource.name.must_equal :architectures
      cmd_c.class.resource.name.must_equal :architectures
    end
  end

  context "apipie generated options" do

    class DocumentedCommand < HammerCLI::Apipie::Command
      def self.resource_config
        { :apidoc_cache_dir => 'test/unit/fixtures/apipie', :apidoc_cache_name => 'documented' }
      end
    end

    let(:cmd_class) { DocumentedCommand.dup }
    let(:cmd) { cmd_class.new("", ctx) }

    context "with one simple param" do

      let(:option) { cmd_class.declared_options[0] }

      before :each do
        cmd_class.resource :documented, :index
        cmd_class.apipie_options
      end

      it "should create an option for the parameter" do
        cmd_class.declared_options.length.must_equal 1
      end

      it "should set correct switch" do
        option.switches.must_be :include?, '--se-arch-val-ue'
      end

      it "should set correct attribute name" do
        option.attribute_name.must_equal HammerCLI.option_accessor_name('se_arch_val_ue')
      end

      it "should set description with html tags stripped" do
        option.description.must_equal 'filter results'
      end
    end

    context "required options" do
      before :each do
        cmd_class.resource :documented, :create
        cmd_class.apipie_options
      end

      let(:required_options) { cmd_class.declared_options.reject{|opt| !opt.required?} }

      it "should set required flag for the required options" do
        required_options.map(&:attribute_name).sort.must_equal [HammerCLI.option_accessor_name("array_param")]
      end
    end

    context "with hash params" do
      before :each do
        cmd_class.resource :documented, :create
        cmd_class.apipie_options
      end

      it "should create options for all parameters except the hash" do
        cmd_class.declared_options.map(&:attribute_name).sort.must_equal HammerCLI.option_accessor_name("array_param", "name", "provider")
      end

      it "should name the options correctly" do
        cmd_class.declared_options.map(&:attribute_name).sort.must_equal HammerCLI.option_accessor_name("array_param", "name", "provider")
      end
    end

    context "array params" do
      before :each do
        cmd_class.resource :documented, :create
        cmd_class.apipie_options
      end

      let(:cmd) do
        cmd_class.new("").tap do |cmd|
          cmd.stubs(:execute).returns(0)
        end
      end

      it "should parse comma separated string to array" do
        cmd.run(["--array-param=valA,valB,valC"])
        cmd.get_option_value(:array_param).must_equal ['valA', 'valB', 'valC']
      end

      it "should parse string to array of length 1" do
        cmd.run(["--array-param=valA"])
        cmd.get_option_value(:array_param).must_equal ['valA']
      end

      it "should parse empty string to empty array" do
        cmd.run(['--array-param='])
        cmd.get_option_value(:array_param).must_equal []
      end

    end


    context "filtering options" do
      before :each do
        cmd_class.resource :documented, :create
      end

      it "should skip filtered options" do
        cmd_class.apipie_options :without => ["provider", "name"]
        cmd_class.declared_options.map(&:attribute_name).sort.must_equal [HammerCLI.option_accessor_name("array_param")]
      end

      it "should skip filtered options defined as symbols" do
        cmd_class.apipie_options :without => [:provider, :name]
        cmd_class.declared_options.map(&:attribute_name).sort.must_equal [HammerCLI.option_accessor_name("array_param")]
      end

      it "should skip single filtered option in array" do
        cmd_class.apipie_options :without => ["provider"]
        cmd_class.declared_options.map(&:attribute_name).sort.must_equal HammerCLI.option_accessor_name("array_param", "name")
      end

      it "should skip single filtered option" do
        cmd_class.apipie_options :without => "provider"
        cmd_class.declared_options.map(&:attribute_name).sort.must_equal HammerCLI.option_accessor_name("array_param", "name")
      end

    end

  end

end

