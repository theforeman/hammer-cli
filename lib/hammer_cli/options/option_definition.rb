require 'clamp'

module HammerCLI
  module Options

    class OptionDefinition < Clamp::Option::Definition

      attr_accessor :value_formatter

      def help_lhs
        super
      end

      def help_rhs
        lines = [
          description.strip,
          format_description.strip,
          value_description.strip
        ]

        rhs = lines.reject(&:empty?).join("\n")
        rhs.empty? ? " " : rhs
      end

      def format_description
        if value_formatter.nil?
          ""
        else
          value_formatter.description
        end
      end

      def value_description
        default_sources = [
          ("$#{@environment_variable}" if defined?(@environment_variable)),
          (@default_value.inspect if defined?(@default_value))
        ].compact

        str = ""
        str += "Can be specified multiple times. " if multivalued?
        str += "Default: " + default_sources.join(", or ") unless default_sources.empty?
        str
      end

      def default_conversion_block
        if !value_formatter.nil?
          value_formatter.method(:format)
        elsif flag?
          Clamp.method(:truthy?)
        end
      end

      def default_value
        if defined?(@default_value)
          if value_formatter
            value_formatter.format(@default_value)
          else
            @default_value
          end
        elsif multivalued?
          []
        end
      end

    end

  end
end
