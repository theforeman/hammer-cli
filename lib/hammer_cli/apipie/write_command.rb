require 'hammer_cli/messages'

module HammerCLI::Apipie

  class WriteCommand < Command

    include HammerCLI::Messages

    def execute
      send_request
      print_message
      return 0
    end

    protected

    def print_message
      msg = success_message
      output.print_message msg unless msg.nil?
    end

    def send_request
      raise "resource or action not defined" unless self.class.resource_defined?
      resource.send(action, request_params)[0]
    end

    def request_params
      method_options
    end

  end

end


