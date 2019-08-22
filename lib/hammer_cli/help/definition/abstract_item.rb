module HammerCLI
  module Help
    class AbstractItem
      INDENT_STEP = 2

      attr_reader :id, :richtext
      attr_accessor :definition

      def initialize(options = {})
        @id = options[:id]
        @indentation = options[:indentation]
        @richtext = options[:richtext] || false
      end

      def build_string
        raise NotImplementedError
      end

      def self.indent(content, indentation = nil)
        indentation ||= ' ' * INDENT_STEP
        content = content.split("\n") unless content.is_a? Array
        content.map do |line|
          (indentation + line).rstrip
        end.join("\n")
      end

      protected

      def build_definition(content)
        raise NotImplementedError
      end

      def indent(content, indentation = nil)
        indentation ||= @indentation
        self.class.indent(content, indentation)
      end
    end
  end
end
