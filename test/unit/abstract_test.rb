require_relative 'test_helper'
require 'tempfile'


describe HammerCLI::AbstractCommand do

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

    it "should return instance of hammer-cli exception handler by default" do
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

  context "settings loader" do

    module ModA
      module ModB
        class TestCmd < HammerCLI::AbstractCommand
          def config_path
            settings = Tempfile.new 'settings'
            settings << ":host: 'https://localhost.localdomain/'\n"
            settings.close
            [settings.to_path]
          end
        end
      end
    end

    it "should load settings and override based on priority" do

      cmd = ModA::ModB::TestCmd.new ""
      cmd.expects(:execute).returns(0) do
        assert_equals 'https://localhost.localdomain/', context[:settings]["host"]
      end
      cmd.run([])

    end

  end

end

