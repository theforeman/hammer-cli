require 'hammer_cli/messages'

module HammerCLI::Apipie

  class WriteCommand < Command

    include HammerCLI::Messages

    def execute
      response = send_request
      print_success_message(response)
      return HammerCLI::EX_OK
    end

    protected

    def success_message_params(response)
      response
    end

    def print_success_message(response)
      if success_message
        print_message(
          success_message,
          success_message_params(response)
        )
      end
    end

    def send_request
      resource.call(action, request_params)[0]
    end

    def request_params
      method_options
    end

  end

end


