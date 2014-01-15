require File.join(File.dirname(__FILE__), 'test_helper')


describe HammerCLI::Modules do

  module HammerCLITom
    def self.version
      Gem::Version.new "0.0.1"
    end
  end

  module HammerCliJerry
    def self.version
      Gem::Version.new "0.0.2"
    end
  end

  before :each do
    HammerCLI::Settings.clear
    HammerCLI::Settings.load({
      :modules => ["hammer_cli_tom", "hammer_cli_jerry"]
    })

    @log_output = Logging::Appenders['__test__']
    @log_output.reset
  end

  describe "names" do
    it "must return list of modules" do
      HammerCLI::Modules.names.must_equal ["hammer_cli_tom", "hammer_cli_jerry"]
    end

    it "must return empty array by default" do
      HammerCLI::Settings.clear
      HammerCLI::Modules.names.must_equal []
    end
  end

  describe "find by name" do
    it "must return nil if the module does not exist" do
      HammerCLI::Modules.find_by_name("hammer_cli_unknown").must_equal nil
    end

    it "must must find the module" do
      HammerCLI::Modules.find_by_name("hammer_cli_jerry").must_equal HammerCliJerry
    end

    it "must find the module with capital CLI in it's name" do
      HammerCLI::Modules.find_by_name("hammer_cli_tom").must_equal HammerCLITom
    end
  end

  describe "load all modules" do

    it "must call load for each module" do
      HammerCLI::Modules.expects(:load).with("hammer_cli_tom")
      HammerCLI::Modules.expects(:load).with("hammer_cli_jerry")
      HammerCLI::Modules.load_all
    end

  end

  describe "load a module" do
    describe "success" do
      before :each do
        HammerCLI::Modules.stubs(:require_module)
      end

      it "must require a module" do
        HammerCLI::Modules.expects(:require_module).with("hammer_cli_tom")
        HammerCLI::Modules.load("hammer_cli_tom")
      end

      it "must log module's name and version" do
        HammerCLI::Modules.expects(:require_module).with("hammer_cli_tom")
        HammerCLI::Modules.load("hammer_cli_tom")
        @log_output.readline.strip.must_equal "INFO  Modules : Extension module hammer_cli_tom (0.0.1) loaded"
      end

      it "must return true when load succeeds" do
        HammerCLI::Modules.load("hammer_cli_tom").must_equal true
      end

      it "must return true when load! succeeds" do
        HammerCLI::Modules.load!("hammer_cli_tom").must_equal true
      end
    end

    describe "module not found" do
      before :each do
        HammerCLI::Modules.stubs(:require_module).raises(LoadError)
        @error_msg = "ERROR  Modules : Module hammer_cli_tom not found"
      end

      it "must log an error if the load! fails" do
        proc { HammerCLI::Modules.load!("hammer_cli_tom") }.must_raise LoadError
        @log_output.readline.strip.must_equal @error_msg
      end

      it "must log an error if the load fails" do
        HammerCLI::Modules.load("hammer_cli_tom")
        @log_output.readline.strip.must_equal @error_msg
      end

      it "must return false when load fails" do
        HammerCLI::Modules.load("hammer_cli_tom").must_equal false
      end
    end

    describe "module runtime exception" do
      before :each do
        HammerCLI::Modules.stubs(:require_module).raises(RuntimeError)
        @error_msg = "ERROR  Modules : Error while loading module hammer_cli_tom"
        @warning_msg = "Warning: An error occured while loading module hammer_cli_tom"
      end

      it "must log an error if the load! fails" do
        proc {
          proc {
            HammerCLI::Modules.load!("hammer_cli_tom")
          }.must_output("#{@warning_msg}\n", "")
        }.must_raise RuntimeError
        @log_output.readline.strip.must_equal @error_msg
      end

      it "must log an error if the load fails" do
        proc {
          HammerCLI::Modules.load("hammer_cli_tom")
        }.must_output("#{@warning_msg}\n", "")
        @log_output.readline.strip.must_equal @error_msg
      end

      it "must return false when load fails" do
        proc {
          HammerCLI::Modules.load("hammer_cli_tom").must_equal false
        }.must_output("#{@warning_msg}\n", "")
      end
    end

  end

end

