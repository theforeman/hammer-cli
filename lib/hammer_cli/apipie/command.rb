require File.join(File.dirname(__FILE__), '../abstract')
require File.join(File.dirname(__FILE__), '../messages')
require File.join(File.dirname(__FILE__), 'options')
require File.join(File.dirname(__FILE__), 'option_definition')
require File.join(File.dirname(__FILE__), 'resource')

module HammerCLI::Apipie

  class Command < HammerCLI::AbstractCommand

    include HammerCLI::Apipie::Resource
    include HammerCLI::Apipie::Options
    include HammerCLI::Messages

    def self.desc(desc=nil)
      super(desc) || resource.action(action).apidoc[:apis][0][:short_description] || " "
    rescue
      " "
    end

    def self.create_option_builder
      builder = super
      builder.builders += [
        OptionBuilder.new(resource, resource.action(action), :require_options => false)
      ] if resource_defined?
      builder
    end

    def self.apipie_options(*args)
      self.build_options(*args)
    end

    def execute
      d = send_request
      print_data(d)
      return HammerCLI::EX_OK
    end

    def help
      help_str = super
      if !resource || (!action.nil? && !resource.has_action?(action))
        help_str << "\n" + _("Unfortunately the server does not support such operation.") + "\n"
      end
      help_str
    end

    protected

    def send_request
      unless resource && resource.has_action?(action)
        raise HammerCLI::OperationNotSupportedError, _('The server does not support such operation.')
      end
      extended_data(resource.call(action, *extended_request))
    end

    def request_headers
      {}
    end

    def request_options
      {}
    end

    def request_params
      method_options(options)
    end

    def print_data(data)
      print_collection(output_definition, data) unless output_definition.empty?
      print_success_message(data) unless success_message.nil?
    end

    def success_message_params(response)
      response
    end

    def print_success_message(response)
      print_message(
        success_message,
        success_message_params(response)
      )
    end

    def self.option(switches, type, description, opts = {}, &block)
      option = HammerCLI::Apipie::OptionDefinition.new(switches, type, description, opts).tap do |option|
        declared_options << option
        block ||= option.default_conversion_block
        define_accessors_for(option, &block)
      end
      extend_options_help(option) if option.value_formatter.is_a?(HammerCLI::Options::Normalizers::ListNested)
      option
    end

    private

    def extended_request
      params = request_params
      headers = request_headers
      options = request_options
      self.class.command_extensions.each do |extension|
        extension.extend_request_headers(headers)
        extension.extend_request_options(options)
        extension.extend_request_params(params)
      end
      [params, headers, options]
    end

    def extended_data(data)
      self.class.command_extensions.each do |extension|
        extension.extend_before_print(data)
      end
      data
    end
  end
end
