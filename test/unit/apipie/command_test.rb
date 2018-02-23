require File.join(File.dirname(__FILE__), '../test_helper')


describe HammerCLI::Apipie::Command do

  class ParentCommand < HammerCLI::Apipie::Command
    action :show
  end

  class OptionCommand < HammerCLI::Apipie::Command
    resource :architectures, :create

    def option_name
      'test_name'
    end

    def option_operatingsystem_ids
      nil
    end
  end

  class CommandA < HammerCLI::Apipie::Command
    resource :architectures, :index

    class CommandB < ParentCommand
    end
  end

  class CommandC < CommandA
  end

  class CommandUnsupp < HammerCLI::Apipie::Command
    resource :architectures, :unsupptest
  end

  let(:ctx) { { :adapter => :silent, :interactive => false } }
  let(:cmd_class) { HammerCLI::Apipie::Command.dup }
  let(:cmd) { cmd_class.new("", ctx) }
  let(:cmd_run) { cmd.run([]) }

  context "unsupported commands" do
    let(:cmd_class) { CommandUnsupp.dup }
    let(:cmd) { cmd_class.new("unsupported", ctx) }
    it "should print help for unsupported command" do
      assert_match /.*Unfortunately the server does not support such operation.*/, cmd.help
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

  it "should raise exception when no action is defined" do
    cmd.stubs(:handle_exception).returns(HammerCLI::EX_SOFTWARE)
    cmd_run.must_equal HammerCLI::EX_SOFTWARE
  end

  context "resource defined" do
    it "should perform a call to api when resource is defined" do
      ApipieBindings::API.any_instance.expects(:call).returns([])
      cmd.class.resource :architectures, :index
      cmd_run.must_equal 0
    end
  end

  context "options" do

    it "should collect method options from given options" do
      cmd_opt = OptionCommand.new("", ctx)
      params = cmd_opt.class.resource.action(:create).params
      cmd_opt.method_options_for_params(params, {'option_name' => 'name'}).must_equal({"architecture" => {"name" => "name"}})
    end

    it "should collect method options from methods" do
      cmd_opt = OptionCommand.new("", ctx)
      params = cmd_opt.class.resource.action(:create).params
      cmd_opt.method_options_for_params(params, {}).must_equal({"architecture"=>{"name"=>"test_name"}})
    end

  end

end
