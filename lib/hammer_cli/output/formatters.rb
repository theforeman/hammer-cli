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
          @_formatters[type] = FormatterContainer.new(*formatters)
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
      def tags
        %i[]
      end

      def required_features
        return %i[] if tags.empty?

        tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
      end

      def match?(features)
        required_features & features == required_features
      end

      def format(data, field_params={})
        data
      end

      def self.inherited(subclass)
        subclass.define_singleton_method(:method_added) do |method_name|
          if method_name == :tags
            warn(
              _('Method %{tags} for field formatters and output adapters is deprecated. Please use %{feat} or %{req_feat} instead.') % {
                tags: 'tags', feat: 'features', req_feat: 'required_features'
              }
            )
          end
        end
      end
    end

    class FormatterContainer < FieldFormatter

      def initialize(*formatters)
        @formatters = formatters
      end

      def add_formatter(*formatters)
        @formatters += formatters
      end

      def format(data, field_params={})
        @formatters.inject(data) { |d,f| f.format(d, field_params) }
      end

    end

    class ColorFormatter
      def initialize(color)
        @color = color
      end

      def required_features
        return %i[rich_text serialized] if tags.empty?

        tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
      end

      def format(data, field_params={})
        c = HighLine.color(data.to_s, @color)
      end
    end

    class DateFormatter < FieldFormatter

      def required_features
        return %i[serialized] if tags.empty?

        tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
      end

      def format(string_date, field_params={})
        t = DateTime.parse(string_date.to_s)
        t.strftime("%Y/%m/%d %H:%M:%S")
      rescue ArgumentError
        ""
      end
    end

    class ListFormatter < FieldFormatter
      INDENT = "  "

      def required_features
        return %i[serialized] if tags.empty?

        tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
      end

      def format(list, field_params={})
        if list.is_a? Array
          separator = field_params.fetch(:separator, ', ')
          new_line = field_params.fetch(:on_new_line, false)

          list = list.join(separator)
          list ="\n#{list.indent_with(INDENT)}" if new_line
          list
        elsif list
          list.to_s
        else
          ""
        end
      end
    end

    class KeyValueFormatter < FieldFormatter

      def required_features
        return %i[rich_text serialized] if tags.empty?

        tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
      end

      def format(params, field_params={})
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

      def required_features
        return %i[rich_text] if tags.empty?

        tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
      end

      def format(text, field_params={})
        text = text.to_s.indent_with(INDENT) if @indent
        "\n#{text}"
      end
    end

    class InlineTextFormatter < FieldFormatter
      def required_features
        return %i[serialized inline] if tags.empty?

        tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
      end

      def format(text, _field_params = {})
        text.to_s.tr("\r\n", ' ')
      end
    end

    class MultilineTextFormatter < FieldFormatter
      INDENT = '    '.freeze
      MAX_WIDTH = 120
      MIN_WIDTH = 60

      def required_features
        return %i[serialized multiline rich_text] if tags.empty?

        tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
      end

      def format(text, field_params = {})
        width = [[field_params.fetch(:width, 0), MIN_WIDTH].max, MAX_WIDTH].min
        text.to_s.chars.each_slice(width).map(&:join).join("\n")
            .indent_with(INDENT).prepend("\n")
      end
    end

    class BooleanFormatter < FieldFormatter

      def required_features
        return %i[serialized rich_text] if tags.empty?

        tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
      end

      def format(value, field_params={})
        (value == 0 || !value || value == "") ? _("no") : _("yes")
      end
    end

    HammerCLI::Output::Output.register_formatter(DateFormatter.new, :Date)
    HammerCLI::Output::Output.register_formatter(ListFormatter.new, :List)
    HammerCLI::Output::Output.register_formatter(KeyValueFormatter.new, :KeyValue)
    HammerCLI::Output::Output.register_formatter(LongTextFormatter.new, :LongText)
    HammerCLI::Output::Output.register_formatter(InlineTextFormatter.new, :Text)
    HammerCLI::Output::Output.register_formatter(MultilineTextFormatter.new, :Text)
    HammerCLI::Output::Output.register_formatter(BooleanFormatter.new, :Boolean)

  end
end
