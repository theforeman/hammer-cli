require 'hammer_cli/exception_handler'
require 'hammer_cli/logger_watch'
require 'hammer_cli/options/option_definition'
require 'hammer_cli/clamp'
require 'hammer_cli/subcommand'
require 'hammer_cli/options/matcher'
require 'logging'
module HammerCLI

  class AbstractCommand < Clamp::Command
    include HammerCLI::Subcommand

    class << self
      attr_accessor :validation_block
    end

    def adapter
      :base
    end

    def run(arguments)
      exit_code = super
      raise "exit code must be integer" unless exit_code.is_a? Integer
      return exit_code
    rescue => e
      handle_exception e
    end

    def parse(arguments)
      super
      validate_options
      logger.info "Called with options: %s" % options.inspect
    rescue HammerCLI::Validator::ValidationError => e
      signal_usage_error e.message
    end

    def execute
      HammerCLI::EX_OK
    end

    def self.validate_options(&block)
      self.validation_block = block
    end

    def validate_options
      validator.run &self.class.validation_block if self.class.validation_block
    end

    def exception_handler
      @exception_handler ||= exception_handler_class.new(:output => output)
    end

    def initialize(*args)
      super
      context[:path] ||= []
      context[:path] << self
    end

    def parent_command
      context[:path][-2]
    end

    class SortedBuilder < Clamp::Help::Builder

      def default_label_indent
        29
      end

      def add_list(heading, items)
        items.sort! do |a, b|
          a.help[0] <=> b.help[0]
        end

        puts "\n#{heading}:"

        label_width = default_label_indent
        items.each do |item|
          label, description = item.help
          label_width = label.size if label.size > label_width
        end

        items.each do |item|
          label, description = item.help
          description.each_line do |line|
            puts " %-#{label_width}s %s" % [label, line]
            label = ''
          end
        end
      end
    end

    def help
      self.class.help(invocation_path, SortedBuilder.new)
    end

    def self.output(definition=nil, &block)
      dsl = HammerCLI::Output::Dsl.new
      dsl.build &block if block_given?
      output_definition.append definition.fields unless definition.nil?
      output_definition.append dsl.fields
    end

    def output
      @output ||= HammerCLI::Output::Output.new(context, :default_adapter => adapter)
    end

    def output_definition
      self.class.output_definition
    end


    def self.output_definition
      @output_definition = @output_definition || inherited_output_definition || HammerCLI::Output::Definition.new
      @output_definition
    end


    def interactive?
      HammerCLI.interactive?
    end

    def self.option_builder
      @option_builder ||= create_option_builder
      @option_builder
    end

    def self.build_options(builder_params={})
      builder_params = yield(builder_params) if block_given?

      option_builder.build(builder_params).each do |option|
        # skip switches that are already defined
        next if option.nil? or option.switches.any? {|s| find_option(s) }

        declared_options << option
        block ||= option.default_conversion_block
        define_accessors_for(option, &block)
      end
    end

    protected

    def self.find_options(switch_filter, other_filters={})
      filters = other_filters
      if switch_filter.is_a? Hash
        filters.merge!(switch_filter)
      else
        filters[:long_switch] = switch_filter
      end

      m = HammerCLI::Options::Matcher.new(filters)
      recognised_options.find_all do |opt|
        m.matches? opt
      end
    end

    def self.create_option_builder
      OptionBuilderContainer.new
    end

    def print_record(definition, record)
      output.print_record(definition, record)
    end

    def print_collection(definition, collection)
      output.print_collection(definition, collection)
    end

    def print_message(msg, msg_params={})
      output.print_message(msg, msg_params)
    end

    def self.logger(name=self)
      logger = Logging.logger[name]
      logger.extend(HammerCLI::Logger::Watch) if not logger.respond_to? :watch
      logger
    end

    def logger(name=self.class)
      self.class.logger(name)
    end

    def validator
      options = self.class.recognised_options.collect{|opt| opt.of(self)}
      @validator ||= HammerCLI::Validator.new(options)
    end

    def handle_exception(e)
      exception_handler.handle_exception(e)
    end

    def exception_handler_class
      #search for exception handler class in parent modules/classes
      HammerCLI.constant_path(self.class.name.to_s).reverse.each do |mod|
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
      @name || (superclass.respond_to?(:command_name) ? superclass.command_name : nil)
    end

    def self.autoload_subcommands
      commands = constants.map { |c| const_get(c) }.select { |c| c <= HammerCLI::AbstractCommand }
      commands.each do |cls|
        subcommand cls.command_name, cls.desc, cls
      end
    end

    def self.define_simple_writer_for(attribute, &block)
      define_method(attribute.write_method) do |value|
        value = instance_exec(value, &block) if block
        if attribute.respond_to?(:context_target) && attribute.context_target
          context[attribute.context_target] = value
        end
        attribute.of(self).set(value)
      end
    end

    def self.option(switches, type, description, opts = {}, &block)
      HammerCLI::Options::OptionDefinition.new(switches, type, description, opts).tap do |option|
        declared_options << option
        block ||= option.default_conversion_block
        define_accessors_for(option, &block)
      end
    end

    def all_options
      @all_options ||= self.class.recognised_options.inject({}) do |hash, opt|
        hash[opt.attribute_name] = send(opt.read_method)
        hash[opt.attribute_name] = add_custom_defaults(opt.attribute_name) if hash[opt.attribute_name].nil?
        hash
      end
      @all_options
    end

    def options
      all_options.reject {|key, value| value.nil? }
    end

    private

    def add_custom_defaults(attr)
      if context[:defaults]
        value = context[:defaults].get_defaults(attr)
        logger.info("Custom default value #{value} was used for attribute #{attr}") if value
        value
      end
    end
    
    def self.inherited_output_definition
      od = nil
      if superclass.respond_to? :output_definition
        od_super = superclass.output_definition
        od = od_super.dup unless od_super.nil?
      end
      od
    end

  end
end
