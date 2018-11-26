module HammerCLI
  module Options
    class OptionProcessor
      def initialize(name: nil)
        @name = name
      end

      def name
        @name || self.class.name.split('::')[-1]
      end

      def process(defined_options, result)
        result
      end
    end
  end
end
