
module HammerCLI::Output::Adapter

  class Silent < Abstract

    def print_message(msg)
    end

    def print_error(msg, details=[])
    end

    def print_records(fields, data)
    end

  end

  HammerCLI::Output::Output.register_adapter(:silent, Silent)

end
