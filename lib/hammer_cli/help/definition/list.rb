module HammerCLI
  module Help
    class List < AbstractItem
      LIST_INDENT = 20

      def initialize(items, options = {})
        super(options)
        @indent_size = options[:indent_size] || indent_size(items)
        build_definition(items || [])
      end

      def build_string
        out = StringIO.new
        @definition.each do |item|
          out.puts item.build_string
        end
        out.string
      end

      protected

      def build_definition(items)
        @definition = Definition.new
        items.each do |item|
          @definition << Text.new(format_item(item))
        end
        @definition
      end

      private

      def indent_size(items)
        items = normalize(items)
        max_len = items.map { |i| i[0].to_s.length }.max
        (max_len + INDENT_STEP > LIST_INDENT) ? (max_len + INDENT_STEP) : LIST_INDENT
      end

      def format_item(item)
        col1, col2, options = item
        options ||= {}
        col1 = HighLine.color(col1.to_s, :bold) if options[:bold]
        col2 = indent(col2.to_s, ' ' * @indent_size).lstrip
        padding = col1.length - HammerCLI::Output::Utils.real_length(col1)
        line = "%-#{@indent_size + padding}s%s" % [col1, col2]
        line.strip!
        line
      end

      def normalize(items)
        items.map do |i|
          i.is_a?(Array) ? i : [i]
        end
      end
    end
  end
end
