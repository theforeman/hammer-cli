require 'hammer_cli/exception_handler'
require 'hammer_cli/logger_watch'
require 'hammer_cli/options/option_definition'
require 'hammer_cli/options/option_collector'
require 'hammer_cli/options/processor_list'
require 'hammer_cli/options/sources/command_line'
require 'hammer_cli/options/sources/saved_defaults'
require 'hammer_cli/options/validators/dsl_block_validator'
require 'hammer_cli/clamp'
require 'hammer_cli/subcommand'
require 'hammer_cli/options/matcher'
require 'hammer_cli/options/predefined'
require 'hammer_cli/help/builder'
require 'hammer_cli/help/text_builder'
require 'hammer_cli/command_extensions'
require 'hammer_cli/options/option_family'
require 'logging'

module HammerCLI
  class AbstractCommand < Clamp::Command
    include HammerCLI::Subcommand

    attr_reader :context

    class << self
      attr_accessor :validation_blocks

      def family_registry
        @family_registry ||= HammerCLI::Options::OptionFamilyRegistry.new
      end

      def option_families
        ancestors.inject([]) do |registry, ancestor|
          next registry unless ancestor <= HammerCLI::AbstractCommand

          registry + ancestor.family_registry
        end
      end

      def help_extension_blocks
        @help_extension_blocks ||= []
      end

      def command_extensions
        @command_extensions = @command_extensions || inherited_command_extensions || []
        @command_extensions
      end

      def inherited_command_extensions
        extensions = nil
        if superclass.respond_to?(:command_extensions)
          parent_extensions = superclass.command_extensions.select(&:inheritable?)
          extensions = parent_extensions.dup unless parent_extensions.empty?
        end
        extensions
      end

      def add_option_schema(option)
        extend_help do |h|
          option_details = h.find_item(:s_option_details)
          begin
            option_details.definition.find_item(:t_schema_help)
          rescue ArgumentError
            option_details.definition << HammerCLI::Help::Text.new(
              _('Following parameters accept format defined by its schema ' \
                '(bold are required; <> contains acceptable type; [] contains acceptable value):'),
              id: :t_schema_help
            )
          end
          option_details.definition << HammerCLI::Help::List.new([
            [option.switches.last, option.value_formatter.schema.description]
          ])
        end
      end

      def add_option_details_section(help)
        option_details = HammerCLI::Help::Section.new(_('Option details'), nil, id: :s_option_details, richtext: true)
        option_details.definition << HammerCLI::Help::Text.new(
          _('Here you can find option types and the value an option can accept:')
        )
        type_list = HammerCLI::Options::Normalizers.available.each_with_object([]) do |n, l|
          l << [n.completion_type.to_s.upcase, n.common_description]
        end.uniq(&:first).sort

        option_details.definition << HammerCLI::Help::List.new(type_list)
        help.definition.unshift(option_details)
      end

      def add_sets_help(help)
        sets_details = HammerCLI::Help::Section.new(_('Predefined field sets'), nil, id: :s_sets_details, richtext: true)
        sets_details.definition << HammerCLI::Help::Text.new(output_definition.sets_table)
        help.definition.unshift(sets_details)
      end
    end

    def adapter
      :base
    end

    def run(arguments)
      begin
        begin
          exit_code = super
          clean_up_context
          raise "exit code must be integer" unless exit_code.is_a? Integer
        rescue => e
          exit_code = handle_exception(e)
        end
        logger.debug 'Retrying the command' if (exit_code == HammerCLI::EX_RETRY)
      end while (exit_code == HammerCLI::EX_RETRY)
      return exit_code
    end

    def parse(arguments)
      super
      validate_options
      logger.info "Called with options: %s" % options.inspect
    rescue HammerCLI::Options::Validators::ValidationError => e
      signal_usage_error e.message
    end

    def execute
      HammerCLI::EX_OK
    end

    def clean_up_context
      context.delete(:fields)
    end

    def self.validate_options(mode=:append, target_name=nil, validator: nil, &block)
      validator ||= HammerCLI::Options::Validators::DSLBlockValidator.new(&block)
      self.validation_blocks ||= []
      self.validation_blocks << [mode, target_name, validator]
    end

    def validate_options
      # keep the method for legacy reasons
    end

    def exception_handler
      @exception_handler ||= exception_handler_class.new(:output => output)
    end

    def initialize(*args)
      super
      context[:path] ||= []
      context[:path] << self
      self.class.command_extensions.each do |extension|
        extension.command_object(self)
      end
    end

    def parent_command
      context[:path][-2]
    end

    def help
      self.class.help(invocation_path, HammerCLI::Help::Builder.new(context[:is_tty?]))
    end

    def self.help(invocation_path, builder = HammerCLI::Help::Builder.new)
      super(invocation_path, builder)
      help_extension = HammerCLI::Help::TextBuilder.new(builder.richtext)
      fields_switch = HammerCLI::Options::Predefined::OPTIONS[:fields].first[0]
      add_option_details_section(help_extension) if recognised_options.size > 1
      add_sets_help(help_extension) if find_option(fields_switch)
      unless help_extension_blocks.empty?
        help_extension_blocks.each do |extension_block|
          begin
            extension_block.call(help_extension)
          rescue ArgumentError => e
            handler = HammerCLI::ExceptionHandler.new
            handler.handle_exception(e)
          end
        end
      end
      builder.add_text(help_extension.string)
      builder.string
    end

    def self.extend_help(&block)
      # We save the block for execution on object level, where we can access command's context and check :is_tty? flag
      self.help_extension_blocks << block
    end

    def self.extend_output_definition(&block)
      block.call(output_definition)
    rescue ArgumentError => e
      handler = HammerCLI::ExceptionHandler.new
      handler.handle_exception(e)
    end

    def self.output(definition=nil, &block)
      dsl = HammerCLI::Output::Dsl.new
      dsl.build(&block) if block_given?
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

    def self.option(switches, type, description, opts = {}, &block)
      option = HammerCLI::Options::OptionDefinition.new(switches, type, description, opts).tap do |option|
        declared_options << option
        block ||= option.default_conversion_block
        define_accessors_for(option, &block)
        add_option_schema(option) if option.value_formatter.is_a?(HammerCLI::Options::Normalizers::ListNested)
        completion_type_for(option, opts)
      end
      option
    end

    def self.build_options(builder_params={})
      builder_params = yield(builder_params) if block_given?
      builder_params[:command] = self

      option_builder.build(builder_params).each do |option|
        # skip switches that are already defined
        next if option.nil? || option.family || option.switches.any? { |s| find_option(s) }

        declared_options << option
        block ||= option.default_conversion_block
        define_accessors_for(option, &block)
        add_option_schema(option) if option.value_formatter.is_a?(HammerCLI::Options::Normalizers::ListNested)
        completion_type_for(option)
      end
    end

    def self.extend_with(*extensions)
      extensions.each do |extension|
        unless extension.is_a?(HammerCLI::CommandExtensions)
          raise ArgumentError, _('Command extensions should be inherited from %s.') % HammerCLI::CommandExtensions
        end
        extension.delegatee(self)
        extension.command_class(self)
        extension.extend_predefined_options
        extension.extend_options
        extension.extend_option_family
        extension.extend_output
        extension.extend_help
        logger('Extensions').info "Applied #{extension.details} on #{self}."
        command_extensions << extension
      end
    end

    def self.use_option(*names)
      names.each do |name|
        HammerCLI::Options::Predefined.use(name, self)
      end
    end

    def self.option_family(options = {}, &block)
      options[:creator] ||= self
      family = if options[:associate]
                 option_families.find { |f| f.root.to_s == options[:associate].to_s }
               else
                 HammerCLI::Options::OptionFamily.new(options)
               end
      return family.instance_eval(&block) if family

      logger('Option Family').debug "No family found for #{options[:associate]}, skipping"
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

    def print_collection(definition, collection, options = {})
      output.print_collection(definition, collection, options)
    end

    def print_message(msg, msg_params = {}, options = {})
      output.print_message(msg, msg_params, options)
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
      # keep the method for legacy reasons, it's used by validate_options
      @validator ||= HammerCLI::Options::Validators::DSL.new(self.class.recognised_options, all_options)
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
      if @names && name
        @names << name if !@names.include?(name)
      else
        @names = [name] if name
      end
      @names || (superclass.respond_to?(:command_names) ? superclass.command_names : nil)
    end

    def self.command_names(*names)
      @names = names unless names.empty?
      @names || (superclass.respond_to?(:command_names) ? superclass.command_names : nil)
    end

    def self.warning(message = nil)
      @warning_msg = message if message
      @warning_msg
    end

    def self.autoload_subcommands
      commands = constants.map { |c| const_get(c) }.select { |c| c <= HammerCLI::AbstractCommand }
      commands.each do |cls|
        subcommand(cls.command_name, cls.desc, cls, warning: cls.warning)
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

    def all_options
      option_collector.all_options
    end

    def options
      option_collector.options
    end

    def option_collector
      @option_collector ||= HammerCLI::Options::OptionCollector.new(self.class.recognised_options, add_validators(option_sources))
    end

    def option_sources
      sources = HammerCLI::Options::ProcessorList.new(name: 'DefaultInputs')
      sources << HammerCLI::Options::Sources::CommandLine.new(self)
      sources << HammerCLI::Options::Sources::SavedDefaults.new(context[:defaults], logger) if context[:use_defaults]

      sources = HammerCLI::Options::ProcessorList.new([sources])
      self.class.command_extensions.each do |extension|
        extension.extend_option_sources(sources)
      end
      sources
    end

    def add_validators(sources)
      if self.class.validation_blocks
        self.class.validation_blocks.each do |validation_block|
          sources.insert_relative(*validation_block)
        end
      end
      sources
    end

    def self.completion_map
      completion = {}
      # collect options
      recognised_options.each do |opt|
        opt.switches.each do |switch|
          completion[switch] = completion_types.fetch(switch, {})
        end
      end
      # collect subcommands recursively
      recognised_subcommands.each do |cmd|
        completion[cmd.names.first] = cmd.subcommand_class.completion_map
      end
      # collect params
      completion[:params] = completion_types[:params] unless completion_types[:params].empty?
      completion
    end

    def self.completion_types
      @completion_types ||= { :params => [] }
    end

    def self.completion_type_for(option, opts = {})
      completion_type = opts.delete(:completion)
      completion_type ||= option.completion_type(opts[:format])
      [option.switches].flatten(1).each { |s| completion_types[s] = completion_type }
    end

    private

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
