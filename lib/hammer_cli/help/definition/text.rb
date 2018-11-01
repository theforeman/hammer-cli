module HammerCLI
  module Help
    class Text < AbstractItem
      def initialize(text = nil, options = {})
        super(options)
        build_definition(text)
      end

      def build_string
        @text
      end

      protected

      def build_definition(content)
        @text = content || ''
        @definition = Definition.new([self])
      end
    end
  end
end
