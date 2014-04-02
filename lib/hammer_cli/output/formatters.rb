module HammerCLI::Output
  module Formatters

    # Registry for formatters
    class FormatterLibrary
      def initialize(formatter_map={})

        @_formatters = {}
        formatter_map.each do |type, formatters|
          register_formatter(type, *Array(formatters))
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

    # Tags:
    # All the tags the formatter has, needs to be present in the addapter.
    # Otherwise the formatter won't apply. Formatters with :flat tag are used first
    # as we expect them to serialize the value.
    #
    #   - by format: :flat x :data
    #   - by output: :file X :screen

    # abstract formatter
    class FieldFormatter

      def tags
        []
      end

      def match?(other_tags)
        tags & other_tags == tags
      end

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

      def tags
        [:screen, :flat]
      end

      def format(data)
        c = HighLine.color(data.to_s, @color)
      end
    end

    class DateFormatter < FieldFormatter

      def tags
        [:flat]
      end

      def format(string_date)
        t = DateTime.parse(string_date.to_s)
        t.strftime("%Y/%m/%d %H:%M:%S")
      rescue ArgumentError
        ""
      end
    end

    class ListFormatter < FieldFormatter

      def tags
        [:flat]
      end

      def format(list)
        if list.is_a? Array
          list.join(", ")
        elsif list
          list.to_s
        else
          ""
        end
      end
    end

    class KeyValueFormatter < FieldFormatter

      def tags
        [:screen, :flat]
      end

      def format(params)
        if params.is_a? Hash
          name = params[:name] || params["name"]
          value = params[:value] || params["value"]
          "#{name} => #{value}"
        else
          ""
        end
      end
    end

    class LongTextFormatter < FieldFormatter

      INDENT = "  "

      def initialize(options = {})
        @indent = options[:indent].nil? ? true : options[:indent]
      end

      def tags
        [:screen]
      end

      def format(text)
        text = text.to_s.indent_with(INDENT) if @indent
        "\n#{text}"
      end
    end

    class BooleanFormatter < FieldFormatter

      def tags
        [:flat, :screen]
      end

      def format(value)
        !value || value == "" ? _("no") : _("yes")
      end
    end

    HammerCLI::Output::Output.register_formatter(DateFormatter.new, :Date)
    HammerCLI::Output::Output.register_formatter(ListFormatter.new, :List)
    HammerCLI::Output::Output.register_formatter(KeyValueFormatter.new, :KeyValue)
    HammerCLI::Output::Output.register_formatter(LongTextFormatter.new, :LongText)
    HammerCLI::Output::Output.register_formatter(BooleanFormatter.new, :Boolean)

  end
end



