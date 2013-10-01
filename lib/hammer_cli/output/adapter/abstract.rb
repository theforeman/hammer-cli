module HammerCLI::Output::Adapter

  class Abstract

    def tags
      []
    end

    def initialize(context={}, formatters={})
      @context = context
      @formatters = HammerCLI::Output::Formatters::FormatterLibrary.new(filter_formatters(formatters))
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

    private 

    def filter_formatters(formatters_map)
      formatters_map ||= {}
      formatters_map.inject({}) do |map, (type, formatter_list)|
        # remove incompatible formatters
        filtered = formatter_list.select { |f| f.match?(tags) }
        # put serializers first
        map[type] = filtered.sort_by { |f| f.tags.include?(:flat) ? 0 : 1 }
        map
      end
    end

  end
end
