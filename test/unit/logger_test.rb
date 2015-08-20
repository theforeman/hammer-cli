require File.join(File.dirname(__FILE__), 'test_helper')
require 'tempfile'

describe Logging::LogEvent do
  context "filtering" do
    before :each do
      @log_output = Logging::Appenders['__test__']
      @log_output.reset
    end

    it "can filter log data" do
      Logging::LogEvent.add_data_filter(/pat/, 'mat')
      Logging.logger.root.debug "pat"
      Logging::LogEvent.data_filters.pop # clean the last filter
      @log_output.read.must_include 'mat'
    end
  end
end
