
module HammerCLI::Output::Adapter

  class Abstract

    def initialize(context={}, formatters=HammerCLI::Output::Formatters::FormatterLibrary.new)
      @context = context
      @formatters = formatters
    end

    def print_message(msg)
      puts msg
    end

    def print_error(msg, details=nil)
      details = details.split("\n") if details.kind_of? String

      if details
        indent = "  "
        $stderr.puts msg+":"
        $stderr.puts indent + details.join("\n"+indent)
      else
        $stderr.puts msg
      end
    end

    def print_records(fields, data)
      raise NotImplementedError
    end

  end
end
