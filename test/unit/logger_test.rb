require File.join(File.dirname(__FILE__), 'test_helper')
require 'tempfile'

describe Logging::LogEvent do

  describe '#initialize_logger' do
    let(:logger) { Logging::Logger.new(File.open('/dev/null')) }

    it "prints message to stderr when log dir can't be created" do
        log_dir = "/nonexistant/dir/logs"
        FileUtils.expects(:mkdir_p).raises(Errno::EACCES)

        HammerCLI::Settings.load({:log_dir => log_dir})

        _, err = capture_io do
          HammerCLI::Logger::initialize_logger(logger)
        end

        assert_match "No permissions to create log dir #{log_dir}", err
        assert_match "File #{log_dir}/hammer.log not writeable, won't log anything to the file!", err
    end
  end

  context "filtering" do
    before :each do
      @log_output = Logging::Appenders['__test__']
      @log_output.reset
    end

    it "can filter log data" do
      Logging::LogEvent.add_data_filter(/pat/, 'mat')
      Logging.logger.root.debug "pat"
      Logging::LogEvent.data_filters.pop # clean the last filter
      _(@log_output.read).must_include 'mat'
    end
  end
end
