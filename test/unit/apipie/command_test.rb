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


end

