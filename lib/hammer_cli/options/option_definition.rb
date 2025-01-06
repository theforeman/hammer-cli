require 'clamp'

module HammerCLI

  class NilValue; end

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

    NIL_SUBST = 'NIL'

    class OptionDefinition < Clamp::Option::Definition

      attr_accessor :value_formatter, :context_target, :deprecated_switches,
                    :family

      def initialize(switches, type, description, options = {})
        @value_formatter = options[:format] || HammerCLI::Options::Normalizers::Default.new
        @context_target = options[:context_target]
        @deprecated_switches = options[:deprecated]
        @family = options[:family]
        # We expect a value from API param docs, but in case it's not there, we want to show it in help by default
        @show = options.fetch(:show, true)
        super
      end

      def complete(value)
        value_formatter.complete(value)
      end

      def help_lhs
        lhs = switches.join(', ')
        lhs += " #{completion_type[:type]}".upcase unless flag?
        lhs
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

      def extract_value(switch, arguments)
        message = _("Warning: Option %{option} is deprecated. %{message}")
        if deprecated_switches.class <= String && switches.include?(switch)
          warn(message % { option: switch, message: deprecated_switches })
        elsif deprecated_switches.class <= Hash && deprecated_switches.keys.include?(switch)
          warn(message % { option: switch, message: deprecated_switches[switch] })
        end
        super(switch, arguments)
      end

      def deprecation_message(switch)
        if deprecated_switches.class <= String && switches.include?(switch)
          deprecated_switches
        elsif deprecated_switches.class <= Hash && deprecated_switches.keys.include?(switch)
          deprecated_switches[switch]
        end
      end

      def description
        if deprecated_switches.class <= String
          format_deprecation_msg(super, _('Deprecated: %{deprecated_msg}') % { deprecated_msg: deprecated_switches })
        elsif deprecated_switches.class <= Hash
          full_msg = deprecated_switches.map do |flag, msg|
            _('%{flag} is deprecated: %{deprecated_msg}') % { flag: flag, deprecated_msg: msg }
          end.join(', ')
          format_deprecation_msg(super, full_msg)
        else
          super
        end
      end

      def format_description
        value_formatter.description
      end

      def value_description
        default_sources = [
          ("$#{@environment_variable}" if defined?(@environment_variable)),
          (@default_value.inspect if defined?(@default_value))
        ].compact

        str = ""
        if multivalued?
          str += _("Can be specified multiple times.")
          str += " "
        end
        unless default_sources.empty?
          sep = _(", or")
          sep += " "
          str += _("Default:")
          str += " "
          str += default_sources.join(sep)
        end
        str
      end

      def default_conversion_block
        if flag?
          Clamp.method(:truthy?)
        else
          self.method(:format_value)
        end
      end

      def format_value(value)
        if value == nil_subst
          HammerCLI::NilValue
        else
          value_formatter.format(value)
        end
      end

      def nil_subst
        nil_subst = ENV['HAMMER_NIL'] || HammerCLI::Options::NIL_SUBST
        raise _('Environment variable HAMMER_NIL can not be empty.') if nil_subst.empty?
        nil_subst
      end

      def default_value
        if defined?(@default_value)
          value_formatter.format(@default_value)
        elsif multivalued?
          []
        end
      end

      def completion_type(formatter = nil)
        return { type: :flag } if @type == :flag

        formatter ||= value_formatter
        formatter.completion_type
      end

      def child?
        return unless @family

        @family.children.include?(self)
      end

      def show?
        @show
      end

      private

      def format_deprecation_msg(option_desc, deprecation_msg)
        "#{option_desc} (#{deprecation_msg})"
      end

      def infer_attribute_name
        HammerCLI.option_accessor_name(super)
      end

    end

  end
end
