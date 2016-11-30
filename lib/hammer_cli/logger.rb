require 'fileutils'
require 'logging'

module Logging
  class LogEvent
    alias_method :old_initialize, :initialize
    def initialize( logger, level, data, caller_tracing )
      # filter out the passwords
      if data.kind_of? String
        self.class.data_filters.each do |filter|
          data = data.gsub(filter[0], filter[1])
        end
      end
      old_initialize(logger, level, data, caller_tracing)
    end

    def self.add_data_filter(pattern, replacement)
      data_filters << [pattern, replacement]
    end

    private

    def self.data_filters
      @filter_list ||= []
      @filter_list
    end
  end
end

# add password filter: *password => "***"
Logging::LogEvent.add_data_filter(/(password(\e\[0;\d{2}m|\e\[0m|\s|=>|")+\")[^\"]*\"/, '\1***"')

module HammerCLI
  module Logger

    Logging.color_scheme('bright',
                         :levels => {
                             :info  => :green,
                             :warn  => :yellow,
                             :error => :red,
                             :fatal => [:white, :on_red]},
                         :date   => :blue,
                         :logger => :cyan,
                         :line   => :yellow,
                         :file   => :yellow,
                         :method => :yellow)

    pattern         = "#{HammerCLI::Settings.get(:log_pattern) || '[%5l %d %c] %m'}\n"
    COLOR_LAYOUT    = Logging::Layouts::Pattern.new(:pattern => pattern, :color_scheme => 'bright')
    NOCOLOR_LAYOUT  = Logging::Layouts::Pattern.new(:pattern => pattern, :color_scheme => nil)
    DEFAULT_LOG_DIR = '/var/log/hammer'

    def self.initialize_logger(logger)
      log_dir = File.expand_path(HammerCLI::Settings.get(:log_dir) || DEFAULT_LOG_DIR)
      begin
        FileUtils.mkdir_p(log_dir, :mode => 0750)
      rescue Errno::EACCES => e
        $stderr.puts _("No permissions to create log dir %s") % log_dir
      end

      filename = "#{log_dir}/hammer.log"
      begin
        logger.appenders = ::Logging.appenders.rolling_file('configure',
                                                            :filename => filename,
                                                            :layout   => NOCOLOR_LAYOUT,
                                                            :truncate => false,
                                                            :keep     => 5,
                                                            :size     => (HammerCLI::Settings.get(:log_size) || 1)*1024*1024) # 1MB
        # set owner and group (it's ignored if attribute is nil)
        FileUtils.chown HammerCLI::Settings.get(:log_owner), HammerCLI::Settings.get(:log_group), filename
      rescue ArgumentError => e
        $stderr.puts _("File %s not writeable, won't log anything to the file!") % filename
      end

      logger.level = HammerCLI::Settings.get(:log_level)
      logger
    end

    initialize_logger(Logging.logger.root)
  end

end
