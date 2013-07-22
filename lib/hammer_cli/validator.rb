
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
        raise "Unknown option name '%s'" % name unless @options.has_key? name
        @options[name]
      end

      def option_passed?(option_name)
        !get_option(option_name).get.nil?
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
        @rejected_msg = "You can't set all options %s at one time"
        @required_msg = "Options %s are required"
      end

      def exist?
        @to_check.each do |opt|
          return false unless option_passed?(opt)
        end
        return true
      end
    end


    class AnyConstraint < BaseConstraint

      def initialize(options, to_check)
        super(options, to_check)
        @rejected_msg = "You can't set any of options %s"
        @required_msg = "At least one of options %s is required"
      end

      def exist?
        @to_check.each do |opt|
          return true if option_passed?(opt)
        end
        return false
      end
    end


    def initialize(options)
      @options = options
    end

    def all(*to_check)
      AllConstraint.new(@options, to_check)
    end

    def option(to_check)
      all(to_check)
    end

    def any(*to_check)
      AnyConstraint.new(@options, to_check)
    end

    def run(&block)
      self.instance_eval &block
    end

  end

end
