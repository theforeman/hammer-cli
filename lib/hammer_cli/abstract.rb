require 'hammer_cli/autocompletion'
require 'hammer_cli/exception_handler'
require 'hammer_cli/logger_watch'
require 'clamp'
require 'logging'

module HammerCLI

  class AbstractCommand < Clamp::Command

    extend Autocompletion
    class << self
      attr_accessor :validation_block
    end

    def run(arguments)
      exit_code = super(arguments)
      raise "exit code must be integer" unless exit_code.is_a? Integer
      return exit_code
    rescue => e
      # do not catch Clamp errors
      raise if e.class <= Clamp::UsageError || e.class <= Clamp::HelpWanted
      handle_exception e
    end

    def parse(arguments)
      super(arguments)
      validate_options
      logger.info "Called with options: %s" % options.inspect
    rescue HammerCLI::Validator::ValidationError => e
      signal_usage_error e.message
    end

    def execute
      HammerCLI::EX_OK
    end

    def self.validate_options &block
      self.validation_block = block
    end

    def validate_options
      validator.run &self.class.validation_block if self.class.validation_block
    end

    def output
      @output ||= HammerCLI::Output::Output.new
    end

    def exception_handler
      @exception_handler ||= exception_handler_class.new :output => output
    end

    protected

    def logger name=self.class
      logger = Logging.logger[name]
      logger.extend(HammerCLI::Logger::Watch) if not logger.respond_to? :watch
      logger
    end

    def validator
      options = self.class.recognised_options.collect{|opt| opt.of(self)}
      @validator ||= HammerCLI::Validator.new(options)
    end

    def handle_exception e
      exception_handler.handle_exception(e)
    end

    def exception_handler_class
      #search for exception handler class in parent modules/classes
      module_list = self.class.name.to_s.split('::').inject([Object]) do |mod, class_name|
        mod << mod[-1].const_get(class_name)
      end
      module_list.reverse.each do |mod|
        return mod.send(:exception_handler_class) if mod.respond_to? :exception_handler_class
      end
      return HammerCLI::ExceptionHandler
    end

    def self.desc(desc=nil)
      @desc = desc if desc
      @desc
    end

    def self.command_name(name=nil)
      @name = name if name
      @name
    end

    def self.autoload_subcommands
      commands = constants.map { |c| const_get(c) }.select { |c| c <= HammerCLI::AbstractCommand }
      commands.each do |cls|
        subcommand cls.command_name, cls.desc, cls
      end
    end

    def all_options
      self.class.recognised_options.inject({}) do |h, opt|
        h[opt.attribute_name] = send(opt.read_method)
        h
      end
    end

    def options
      all_options.reject {|key, value| value.nil? }
    end

  end
end
