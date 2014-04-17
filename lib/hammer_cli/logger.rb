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
    DEFAULT_LOG_DIR = '/var/log/hammer'

    log_dir = File.expand_path(HammerCLI::Settings.get(:log_dir) || DEFAULT_LOG_DIR)
    begin
      FileUtils.mkdir_p(log_dir, :mode => 0750)
    rescue Errno::EACCES => e
      puts _("No permissions to create log dir %s") % log_dir
    end

    logger   = Logging.logger.root
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
      puts _("File %s not writeable, won't log anything to the file!") % filename
    end

    logger.level = HammerCLI::Settings.get(:log_level)

  end

end
