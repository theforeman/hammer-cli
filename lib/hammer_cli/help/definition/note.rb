module HammerCLI
  module Help
    class Note < Text
      def initialize(text, options = {})
        @label = options[:label] || _('NOTE')
        super
      end

      def build_string
        @text
      end

      protected

      def build_definition(content)
        @text = heading + ' '
        @text += content.to_s
        @definition = Definition.new([self])
      end

      private

      def heading
        @label += ':'
        @label = HighLine.color(@label, :bold) if @richtext
        @label
      end
    end
  end
end
