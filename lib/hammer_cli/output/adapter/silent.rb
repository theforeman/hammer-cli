
module HammerCLI::Output::Adapter

  class Silent < Abstract

    def print_message(msg, msg_params={})
    end

    def print_error(msg, details=[], msg_params={})
    end

    def print_record(fields, record)
    end

    def print_collection(fields, collection, options = {})
    end

  end

  HammerCLI::Output::Output.register_adapter(:silent, Silent)

end
