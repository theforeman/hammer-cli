module HammerCLI
  module Help
    class Section < AbstractItem
      attr_reader :label

      def initialize(label, definition = nil, options = {})
        super(options)
        @label = label
        @richtext = options[:richtext] || false
        @id ||= label
        build_definition(definition)
      end

      def build_string
        out = StringIO.new
        out.puts heading
        out.puts indent(@definition.build_string)
        out.string
      end

      protected

      def build_definition(content)
        @definition = content || Definition.new
      end

      private

      def heading
        label = "#{@label}:"
        label = HighLine.color(label, :bold) if @richtext
        label
      end
    end
  end
end
