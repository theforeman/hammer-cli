require 'fileutils'
require 'logging'

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

    pattern         = "[%5l %d %c] %m\n"
    COLOR_LAYOUT    = Logging::Layouts::Pattern.new(:pattern => pattern, :color_scheme => 'bright')
    NOCOLOR_LAYOUT  = Logging::Layouts::Pattern.new(:pattern => pattern, :color_scheme => nil)
    DEFAULT_LOG_DIR = '/var/log/foreman'

    log_dir = File.expand_path(HammerCLI::Settings[:log_dir] || DEFAULT_LOG_DIR)
    begin
      FileUtils.mkdir_p(log_dir, :mode => 0750)
    rescue Errno::EACCES => e
      puts "No permissions to create log dir #{log_dir}"
    end

    logger   = Logging.logger.root
    filename = "#{log_dir}/hammer.log"
    begin
      logger.appenders = ::Logging.appenders.rolling_file('configure',
                                                          :filename => filename,
                                                          :layout   => NOCOLOR_LAYOUT,
                                                          :truncate => false,
                                                          :keep     => 5,
                                                          :size     => HammerCLI::Settings[:log_size] || 1024*1024) # 1MB
      # set owner and group (it's ignored if attribute is nil)
      FileUtils.chown HammerCLI::Settings[:log_owner], HammerCLI::Settings[:log_group], filename
    rescue ArgumentError => e
      puts "File #{filename} not writeable, won't log anything to file!"
    end

    logger.level = HammerCLI::Settings[:log_level]

  end 

end
