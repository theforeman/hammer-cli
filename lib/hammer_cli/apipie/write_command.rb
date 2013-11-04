require 'hammer_cli/messages'

module HammerCLI::Apipie

  class WriteCommand < Command

    include HammerCLI::Messages

    def execute
      send_request
      print_success_message 
      return HammerCLI::EX_OK
    end

    protected

    def print_success_message
      msg = success_message
      print_message(msg) unless msg.nil?
    end

    def send_request
      resource.call(action, request_params)[0]
    end

    def request_params
      method_options
    end

  end

end


