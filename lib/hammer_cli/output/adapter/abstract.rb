module HammerCLI::Output::Adapter

  class Abstract

    def tags
      []
    end

    def initialize(context={}, formatters={})
      @context = context
      @formatters = HammerCLI::Output::Formatters::FormatterLibrary.new(filter_formatters(formatters))
    end

    def print_message(msg, msg_params={})
      puts msg.format(msg_params)
    end

    def print_error(msg, details=nil, msg_params={})
      details = details.split("\n") if details.kind_of? String

      if details
        indent = "  "
        msg += ":\n"
        msg += indent + details.join("\n"+indent)
      end

      $stderr.puts msg.format(msg_params)
    end

    def print_record(fields, record)
      raise NotImplementedError
    end

    def print_collection(fields, collection)
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
