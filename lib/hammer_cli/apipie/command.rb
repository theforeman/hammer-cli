require File.join(File.dirname(__FILE__), '../abstract')
require File.join(File.dirname(__FILE__), '../messages')
require File.join(File.dirname(__FILE__), 'options')
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

    def self.custom_option_builders
      builders = super
      builders += [
        OptionBuilder.new(resource.action(action), :require_options => false)
      ] if resource_defined?
      builders
    end

    def self.apipie_options(*args)
      self.build_options(*args)
    end

    def execute
      d = send_request
      print_data(d)
      return HammerCLI::EX_OK
    end

    protected

    def send_request
      if resource && resource.has_action?(action)
        resource.call(action, request_params, request_headers)
      else
        raise HammerCLI::OperationNotSupportedError, "The server does not support such operation."
      end
    end

    def request_headers
      {}
    end

    def request_params
      method_options
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

  end
end
