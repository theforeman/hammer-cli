module HammerCLI
  class CommandExtensions
    class << self
      attr_accessor :delegatee

      def logger
        Logging.logger[to_s]
      end

      def inheritable?
        @inheritable
      end
    end

    ALLOWED_EXTENSIONS = %i[
      option command_options before_print data output help request
      request_headers headers request_options options request_params params
      option_sources predefined_options use_option option_family
    ].freeze

    def initialize(options = {})
      @only = options[:only] || ALLOWED_EXTENSIONS
      @only = [@only] unless @only.is_a?(Array)
      @except = options[:except] || []
      @except = [@except] unless @except.is_a?(Array)
      @inheritable = options[:inheritable]
    end

    def inheritable?
      return @inheritable unless @inheritable.nil?

      self.class.inheritable? || false
    end

    def self.method_missing(message, *args, &block)
      if @delegatee
        @delegatee.send(message, *args, &block)
      else
        super
      end
    end

    # DSL

    def self.inheritable(boolean)
      @inheritable = boolean
    end

    def self.option(switches, type, description, opts = {}, &block)
      @options ||= []
      @options << { switches: switches,
                    type: type,
                    description: description,
                    opts: opts, block: block }
    end

    def self.use_option(*names)
      @predefined_option_names = names
    end

    def self.before_print(&block)
      @before_print_block = block
    end

    def self.output(&block)
      @output_extension_block = block
    end

    def self.help(&block)
      @help_extension_block = block
    end

    def self.request_headers(&block)
      @request_headers_block = block
    end

    def self.request_options(&block)
      @request_options_block = block
    end

    def self.request_params(&block)
      @request_params_block = block
    end

    def self.option_sources(&block)
      @option_sources_block = block
    end

    def self.option_family(options = {}, &block)
      @option_family_extensions ||= []
      @option_family_extensions << {
        options: options,
        block: block
      }
    end

    # Object

    def extend_options
      allowed = @only & %i[command_options option]
      return if allowed.empty? || (allowed & @except).any?

      self.class.extend_options(@command_class)
    end

    def extend_predefined_options
      allowed = @only & %i[predefined_options use_option]
      return if allowed.empty? || (allowed & @except).any?

      self.class.extend_predefined_options(@command_class)
    end

    def extend_before_print(data)
      allowed = @only & %i[before_print data]
      return if allowed.empty? || (allowed & @except).any?

      self.class.extend_before_print(data, @command_object, @command_class)
    end

    def extend_output
      allowed = @only & %i[output]
      return if allowed.empty? || (allowed & @except).any?

      self.class.extend_output(@command_class, @command_object)
    end

    def extend_help
      allowed = @only & %i[help]
      return if allowed.empty? || (allowed & @except).any?

      self.class.extend_help(@command_class)
    end

    def extend_request_headers(headers)
      allowed = @only & %i[request_headers headers request]
      return if allowed.empty? || (allowed & @except).any?

      self.class.extend_request_headers(headers, @command_object, @command_class)
    end

    def extend_request_options(options)
      allowed = @only & %i[request_options options request]
      return if allowed.empty? || (allowed & @except).any?

      self.class.extend_request_options(options, @command_object, @command_class)
    end

    def extend_request_params(params)
      allowed = @only & %i[request_params params request]
      return if allowed.empty? || (allowed & @except).any?

      self.class.extend_request_params(params, @command_object, @command_class)
    end

    def extend_option_sources(sources)
      allowed = @only & %i[option_sources]
      return if allowed.empty? || (allowed & @except).any?

      self.class.extend_option_sources(sources, @command_object, @command_class)
    end

    def extend_option_family
      allowed = @only & %i[option_family]
      return if allowed.empty? || (allowed & @except).any?

      self.class.extend_option_family(@command_class)
    end

    def delegatee(command_class)
      self.class.delegatee = command_class
    end

    def command_class(command_class)
      @command_class = command_class
    end

    def command_object(command_object)
      @command_object = command_object
    end

    def details
      except = @except.empty? ? '*nothing*' : @except
      details = if @only == ALLOWED_EXTENSIONS
                  "*all* except #{except}"
                else
                  "#{@only} only"
                end
      "#{self.class} for #{details}"
    end

    # Class

    def self.extend_options(command_class)
      return if @options.nil?

      @options.each do |option|
        command_class.send(:option,
                           option[:switches],
                           option[:type],
                           option[:description],
                           option[:opts],
                           &option[:block])
        logger.debug("Added option for #{command_class}: #{option}")
      end
    end

    def self.extend_predefined_options(command_class)
      command_class.send(:use_option, *@predefined_option_names)
      logger.debug("Added predefined options for #{command_class}: #{@predefined_option_names}")
    end

    def self.extend_before_print(data, command_object, command_class)
      return if @before_print_block.nil?

      @before_print_block.call(data, command_object, command_class)
      logger.debug("Called block for #{@delegatee} data:\n\t#{@before_print_block}")
    end

    def self.extend_output(command_class, command_object)
      return if @output_extension_block.nil?

      @output_extension_block.call(command_class.output_definition, command_object, command_class)
      logger.debug("Called block for #{@delegatee} output definition:\n\t#{@output_extension_block}")
    end

    def self.extend_help(command_class)
      return if @help_extension_block.nil?

      command_class.help_extension_blocks << @help_extension_block
      logger.debug("Saved block for #{@delegatee} help definition:\n\t#{@help_extension_block}")
    end

    def self.extend_request_headers(headers, command_object, command_class)
      return if @request_headers_block.nil?

      @request_headers_block.call(headers, command_object, command_class)
      logger.debug("Called block for #{@delegatee} request headers:\n\t#{@request_headers_block}")
    end

    def self.extend_request_options(options, command_object, command_class)
      return if @request_options_block.nil?

      @request_options_block.call(options, command_object, command_class)
      logger.debug("Called block for #{@delegatee} request options:\n\t#{@request_options_block}")
    end

    def self.extend_request_params(params, command_object, command_class)
      return if @request_params_block.nil?

      @request_params_block.call(params, command_object, command_class)
      logger.debug("Called block for #{@delegatee} request params:\n\t#{@request_params_block}")
    end

    def self.extend_option_sources(sources, command_object, command_class)
      return if @option_sources_block.nil?

      @option_sources_block.call(sources, command_object, command_class)
      logger.debug("Called block for #{@delegatee} option sources:\n\t#{@option_sources_block}")
    end

    def self.extend_option_family(command_class)
      return if @option_family_extensions.nil?

      @option_family_extensions.each do |extension|
        extension[:options][:creator] = command_class
        command_class.send(:option_family, extension[:options], &extension[:block])
        logger.debug("Called option family block for #{command_class}:\n\t#{extension[:block]}")
      end
    end
  end
end
