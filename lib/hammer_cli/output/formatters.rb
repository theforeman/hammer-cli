module HammerCLI::Output
  module Formatters

    # Registry for formatters    
    class FormatterLibrary
      def initialize(formatter_map={})
        @_formatters = {}
        formatter_map.each do |type, formatters| 
          register_formatter(type, formatters)
        end
      end

      def register_formatter(type, *formatters)
        if @_formatters[type].nil?
          @_formatters[type] = FormatterContainer.new *formatters
        else 
          formatters.each { |f| @_formatters[type].add_formatter(f) }
        end
      end

      def formatter_for_type(type)
        @_formatters[type.name.split('::').last.to_sym]
      end
    end

    # abstract formatter
    class FieldFormatter
      def format(data)
        data
      end
    end

    class FormatterContainer < FieldFormatter

      def initialize(*formatters)
        @formatters = formatters
      end

      def add_formatter(*formatters)
        @formatters += formatters
      end

      def format(data)
        @formatters.inject(data) { |d,f| f.format(d) }
      end

    end

    class ColorFormatter
      def initialize(color)
        @color = color
      end

      def format(data)
        c = HighLine.color(data.to_s, @color)
      end
    end

    class DateFormatter < FieldFormatter
      def format(string_date)
        t = DateTime.parse(string_date.to_s)
        t.strftime("%Y/%m/%d %H:%M:%S")
      rescue ArgumentError
        ""
      end
    end

    class ListFormatter < FieldFormatter
      def format(list)
        list.join(", ") if list
      end
    end

    DEFAULT_FORMATTERS = FormatterLibrary.new( 
      :Date => DateFormatter.new, 
      :List => ListFormatter.new)

  end
end


