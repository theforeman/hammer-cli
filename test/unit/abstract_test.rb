require File.join(File.dirname(__FILE__), 'test_helper')
require 'tempfile'


describe HammerCLI::AbstractCommand do

  context "output" do

    let(:cmd_class) { Class.new(HammerCLI::AbstractCommand) }
    let(:cmd) { cmd_class.new("", { :adapter => :silent }) }
    it "should define adapter" do
      cmd.adapter.must_equal :base
    end

    it "should provide instance of output with default adapter set" do
      cmd.output.default_adapter.must_equal cmd.adapter
    end

    it "should hold instance of output definition" do
      cmd.output_definition.must_be_instance_of HammerCLI::Output::Definition
    end

    it "can append existing definition" do
      definition = HammerCLI::Output::Definition.new
      definition.fields << Fields::Field.new
      definition.fields << Fields::Field.new

      cmd_class.output(definition) do
      end
      cmd_class.output_definition.fields.length.must_equal definition.fields.length
    end

    it "can append existing definition without passing a block" do
      definition = HammerCLI::Output::Definition.new
      definition.fields << Fields::Field.new
      definition.fields << Fields::Field.new

      cmd_class.output(definition)
      cmd_class.output_definition.fields.length.must_equal definition.fields.length
    end

    it "can define fields" do
      cmd_class.output do
        field :test_1, "test 1"
        field :test_2, "test 2"
      end
      cmd_class.output_definition.fields.length.must_equal 2
    end
  end

  context "exception handler" do

    class Handler
      def initialize(options={})
      end
      def handle_exception(e)
        raise e
      end
    end

    module ModA
      module ModB
        class TestCmd < HammerCLI::AbstractCommand
        end
      end
    end

    it "should return instance of hammer cli exception handler by default" do
      cmd = ModA::ModB::TestCmd.new ""
      cmd.exception_handler.must_be_instance_of HammerCLI::ExceptionHandler
    end

    it "should return instance of exception handler class defined in a module" do
      ModA::ModB.expects(:exception_handler_class).returns(Handler)
      cmd = ModA::ModB::TestCmd.new ""
      cmd.exception_handler.must_be_instance_of Handler
    end

    it "should return instance of exception handler class defined deeper in a module hierrarchy" do
      ModA.expects(:exception_handler_class).returns(Handler)
      cmd = ModA::ModB::TestCmd.new ""
      cmd.exception_handler.must_be_instance_of Handler
    end
  end

  context "logging" do

    before :each do
      @log_output = Logging::Appenders['__test__']
      @log_output.reset
    end

    it "should log what has been executed" do
      test_command = Class.new(HammerCLI::AbstractCommand).new("")
      test_command.run []
      @log_output.readline.strip.must_equal "INFO  HammerCLI::AbstractCommand : Called with options: {}"
    end

    it "password should be hidden in logs" do
      test_command_class = Class.new(HammerCLI::AbstractCommand)
      test_command_class.option(['--password'], 'PASSWORD', 'Password')
      test_command = test_command_class.new("")
      test_command.run ['--password=pass']
      @log_output.readline.strip.must_equal "INFO  HammerCLI::AbstractCommand : Called with options: {\"option_password\"=>\"***\"}"
    end

    class TestLogCmd < HammerCLI::AbstractCommand
      def execute
        logger.error "Test"
        0
      end
    end

    it "should have logger named by the class by default" do
      test_command = Class.new(TestLogCmd).new("")
      test_command.run []
      @log_output.read.must_include "ERROR  TestLogCmd : Test"
    end

    class TestLogCmd2 < HammerCLI::AbstractCommand
      def execute
        logger('My logger').error "Test"
        0
      end
    end

    it "should have logger that accepts custom name" do
      test_command = Class.new(TestLogCmd2).new("")
      test_command.run []
      @log_output.read.must_include "ERROR  My logger : Test"
    end

    class TestLogCmd3 < HammerCLI::AbstractCommand
      def execute
        logger.watch "Test", {}
        0
      end
    end

    it "should have logger that can inspect object" do
      test_command = Class.new(TestLogCmd3).new("")
      test_command.run []
      @log_output.read.must_include "DEBUG  TestLogCmd3 : Test\n{}"
    end

    class TestLogCmd4 < HammerCLI::AbstractCommand
      def execute
        logger.watch "Test", { :a => 'a' }, { :plain => true }
        0
      end
    end

    it "should have logger.watch output without colors" do
      test_command = Class.new(TestLogCmd4).new("")
      test_command.run []
      @log_output.read.must_include "DEBUG  TestLogCmd4 : Test\n{\n  :a => \"a\"\n}"
    end

    class TestLogCmd5 < HammerCLI::AbstractCommand
      def execute
        logger.watch "Test", { :a => 'a' }
        0
      end
    end

    it "should have logger.watch colorized output switch in settings" do
      test_command = Class.new(TestLogCmd5).new("")
      HammerCLI::Settings.clear
      HammerCLI::Settings.load(:watch_plain => true)
      test_command.run []
      @log_output.read.must_include "DEBUG  TestLogCmd5 : Test\n{\n  :a => \"a\"\n}"
    end
  end

  context "subcommand behavior" do

    class Subcommand1 < HammerCLI::AbstractCommand; end
    class Subcommand2 < HammerCLI::AbstractCommand; end

    let(:main_cmd) { HammerCLI::AbstractCommand.dup }

    before :each do
      @log_output = Logging::Appenders['__test__']
      @log_output.reset

      main_cmd.recognised_subcommands.clear
      main_cmd.subcommand("some_command", "description", Subcommand1)
      main_cmd.subcommand("ping", "description", Subcommand1)
    end

    describe "subcommand!" do

      it "should replace commands with the same name" do
        main_cmd.subcommand!("ping", "description", Subcommand2)
        main_cmd.find_subcommand("some_command").wont_be_nil
        main_cmd.find_subcommand("ping").wont_be_nil
        main_cmd.find_subcommand("ping").subcommand_class.must_equal Subcommand2
        main_cmd.recognised_subcommands.count.must_equal 2
      end

      it "should write a message to log when replacing subcommand" do
        main_cmd.subcommand!("ping", "description", Subcommand2)
        @log_output.readline.strip.must_equal "INFO  Clamp::Command : subcommand ping (Subcommand1) was removed."
        @log_output.readline.strip.must_equal "INFO  Clamp::Command : subcommand ping (Subcommand2) was created."
      end

      it "should add the subcommand" do
        main_cmd.subcommand!("new_command", "description", Subcommand2)
        main_cmd.find_subcommand("new_command").wont_be_nil
        main_cmd.find_subcommand("some_command").wont_be_nil
        main_cmd.find_subcommand("ping").wont_be_nil
        main_cmd.recognised_subcommands.count.must_equal 3
      end

    end


    describe "subcommand" do

      it "should throw an exception for conflicting commands" do
        proc do
          main_cmd.subcommand("ping", "description", Subcommand2)
        end.must_raise HammerCLI::CommandConflict
      end

      it "should add the subcommand" do
        main_cmd.subcommand("new_command", "description", Subcommand2)
        main_cmd.find_subcommand("new_command").wont_be_nil
        main_cmd.find_subcommand("some_command").wont_be_nil
        main_cmd.find_subcommand("ping").wont_be_nil
        main_cmd.recognised_subcommands.count.must_equal 3
      end

    end

    describe "remove_subcommand" do
      it "should remove the subcommand" do
        main_cmd.remove_subcommand('ping')
        main_cmd.find_subcommand("ping").must_be_nil
      end

      it "should write a message to log when removing subcommand" do
        main_cmd.remove_subcommand('ping')
        @log_output.readline.strip.must_equal "INFO  Clamp::Command : subcommand ping (Subcommand1) was removed."
      end

    end
  end

  describe "options" do

    class TestOptionCmd < HammerCLI::AbstractCommand
      option "--test", "TEST", "Test option"
      option "--test-format", "TEST_FORMAT", "Test option with a formatter",
        :format => HammerCLI::Options::Normalizers::List.new
    end

    it "should create instances of hammer options" do
      opt = TestOptionCmd.find_option("--test")
      opt.kind_of?(HammerCLI::Options::OptionDefinition).must_equal true
    end

    it "should set options' formatters" do
      opt = TestOptionCmd.find_option("--test-format")
      opt.value_formatter.kind_of?(HammerCLI::Options::Normalizers::List).must_equal true
    end

  end

  describe "build options" do

    class TestOptionBuilder

      def build(build_options={})
        [
          HammerCLI::Options::OptionDefinition.new(["--test"], "TEST", "test"),
          HammerCLI::Options::OptionDefinition.new(["--test2"], "TEST2", "test2")
        ]
      end

    end

    class TestBuilderCmd < HammerCLI::AbstractCommand

      def self.option_builder
        TestOptionBuilder.new
      end

    end

    before :each do
      # define implicit options and clear them all
      TestBuilderCmd.recognised_options
      TestBuilderCmd.declared_options.clear
    end

    it "should use option builder" do
      TestBuilderCmd.build_options
      TestBuilderCmd.recognised_options.map(&:switches).flatten.sort.must_equal ["--test", "--test2"].sort
    end

    it "should skip options that already exist" do
      TestBuilderCmd.option(["--test"], "TEST", "original_test")
      TestBuilderCmd.build_options
      TestBuilderCmd.recognised_options.map(&:description).flatten.sort.must_equal ["original_test", "test2"].sort
    end

  end

  it "should inherit command_name" do
    class CmdName1 < HammerCLI::AbstractCommand
      command_name 'cmd'
    end

    class CmdName2 < CmdName1
    end

    CmdName2.command_name.must_equal 'cmd'
  end

  it "should inherit output definition" do
    class CmdOD1 < HammerCLI::AbstractCommand
      output do
        label 'Label' do
        end
      end
    end

    class CmdOD2 < CmdOD1
    end

    CmdOD2.output_definition.fields.length.must_equal 1
  end

end

