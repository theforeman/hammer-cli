
module HammerCLI

  class Validator

    class ValidationError < StandardError
    end

    class BaseConstraint

      attr_reader :rejected_msg, :required_msg

      def initialize(options, to_check)
        @to_check = to_check
        @rejected_msg = ""
        @required_msg = ""

        @options = options.inject({}) do |hash, opt|
          hash.update({opt.attribute.attribute_name => opt})
        end
      end

      def rejected(args={})
        msg = args[:msg] || rejected_msg % option_switches.join(", ")
        raise ValidationError.new(msg) if exist?
      end

      def required(args={})
        msg = args[:msg] || required_msg % option_switches.join(", ")
        raise ValidationError.new(msg) unless exist?
      end

      def exist?
        raise NotImplementedError
      end

      protected

      def get_option(name)
        name = name.to_s
        raise _("Unknown option name '%s'") % name unless @options.has_key? name
        @options[name]
      end

      def get_option_value(name)
        opt = get_option(name)
        value = opt.get
        value = opt.command.send(:context)[:defaults].get_defaults(name.to_s) if value.nil?
        value
      end

      def option_passed?(option_name)
        !get_option_value(option_name).nil?
      end

      def option_switches(opts=nil)
        opts ||= @to_check
        opts.collect do |option_name|
          get_option(option_name).attribute.long_switch || get_option(option_name).attribute.switches.first
        end
      end

    end

    class AllConstraint < BaseConstraint

      def initialize(options, to_check)
        super(options, to_check)
        @rejected_msg = _("You can't set all options %s at one time")
        @required_msg = _("Options %s are required")
      end

      def exist?
        @to_check.each do |opt|
          return false unless option_passed?(opt)
        end
        return true
      end
    end

    class OneOptionConstraint < AllConstraint
      def initialize(options, to_check)
        super(options, [to_check])
        @rejected_msg = _("You can't set option %s")
        @required_msg = _("Option %s is required")
      end

      def value
        get_option_value(@to_check[0])
      end
    end

    class AnyConstraint < BaseConstraint

      def initialize(options, to_check)
        super(options, to_check)
        @rejected_msg = _("You can't set any of options %s")
        @required_msg = _("At least one of options %s is required")
      end

      def exist?
        @to_check.each do |opt|
          return true if option_passed?(opt)
        end
        return @to_check.empty?
      end
    end


    class OneOfConstraint < BaseConstraint
      def initialize(options, to_check)
        raise 'Set at least one expected option' if to_check.empty?
        super(options, to_check)
      end

      def rejected
        raise NotImplementedError, '#rejected is unsupported for OneOfConstraint'
      end

      def required_msg
        case count_present_options
        when 0
          _("One of options %s is required")
        when 1
          ''
        else
          _("Only one of options %s can be set")
        end
      end

      def exist?
        return count_present_options == 1
      end

      protected
      def count_present_options
        @to_check.count do |opt|
          option_passed?(opt)
        end
      end
    end

    def initialize(options)
      @options = options
    end

    def all(*to_check)
      AllConstraint.new(@options, to_check.flatten(1))
    end

    def option(to_check)
      OneOptionConstraint.new(@options, to_check)
    end

    def any(*to_check)
      AnyConstraint.new(@options, to_check.flatten(1))
    end

    def one_of(*to_check)
      OneOfConstraint.new(@options, to_check.flatten(1))
    end

    def run(&block)
      self.instance_eval &block
    end

  end

end
