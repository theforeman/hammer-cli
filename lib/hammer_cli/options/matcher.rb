
module HammerCLI
  module Options

    class Matcher

      def initialize(filter)
        @filter = filter
      end

      def matches?(option)
        @filter.each do |attribute, filter|
          return false if !attribute_matches?(option, attribute, filter)
        end
        return true
      end

      protected

      def attribute_matches?(option, attribute, filter)
        if filter.is_a? Array
          return filter.any? {|filter_part| attribute_matches?(option, attribute, filter_part)}
        elsif filter.is_a? Regexp
          return attribute_matches_regexp?(option, attribute, filter)
        else
          return attribute_matches_value?(option, attribute, filter)
        end
      end

      def attribute_matches_value?(option, attribute, filter)
        get_attribute_value(option, attribute) == filter
      end

      def attribute_matches_regexp?(option, attribute, filter)
        get_attribute_value(option, attribute) =~ filter
      end

      def get_attribute_value(option, attribute_name)
        option.send(attribute_name)
      rescue NoMethodError
        nil
      end

    end


  end
end
