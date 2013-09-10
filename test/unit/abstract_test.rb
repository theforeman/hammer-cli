require File.join(File.dirname(__FILE__), 'test_helper')
require 'tempfile'


describe HammerCLI::AbstractCommand do

  context "output" do

    let(:command) { HammerCLI::AbstractCommand.new("") }
    it "should define adapter" do
      command.adapter.must_equal :base
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
      @log_output.readline.strip.must_equal "INFO  HammerCLI::AbstractCommand : Called with options: {\"password\"=>\"***\"}"
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
        @log_output.readline.strip.must_equal "INFO  Clamp::Command : subcommand ping (Subcommand1) replaced with ping (Subcommand2)"
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

end

