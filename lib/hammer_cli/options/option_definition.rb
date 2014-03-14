require 'clamp'

module HammerCLI

  def self.option_accessor_name(*name)
    if name.length > 1
      name.map { |n| _option_accessor_name(n) }
    else
      _option_accessor_name(name.first)
    end
  end

  def self._option_accessor_name(name)
    "option_#{name.to_s}".gsub('-', '_')
  end

  module Options

    class OptionDefinition < Clamp::Option::Definition

      attr_accessor :value_formatter
      attr_accessor :context_target

      def complete(value)
        if value_formatter.nil?
          []
        else
          value_formatter.complete(value)
        end
      end

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
        str += _("Can be specified multiple times. ") if multivalued?
        str += _("Default: ") + default_sources.join(_(", or ")) unless default_sources.empty?
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

      private

      def infer_attribute_name
        HammerCLI.option_accessor_name(super)
      end

    end

  end
end
