
module HammerCLI::Output::Adapter

  class Silent

    def print_message(msg)
    end

    def print_error(msg, details=[])
    end

    def print_records(fields, data, heading=nil)
    end

  end

end
