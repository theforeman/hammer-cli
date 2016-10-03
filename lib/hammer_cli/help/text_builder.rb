module HammerCLI
  module Help
    class TextBuilder
      INDENT_STEP = 2
      LIST_INDENT = 20

      def initialize(richtext = false)
        @out = StringIO.new
        @richtext = richtext
      end

      def string
        @out.string
      end

      def text(content)
        puts unless first_print?
        puts content
      end

      def list(items)
        return if items.empty?

        items = normalize_list(items)
        max_len = items.map { |i| i[0].to_s.length }.max
        indent_size = (max_len + INDENT_STEP > LIST_INDENT) ? (max_len + INDENT_STEP) : LIST_INDENT

        puts unless first_print?
        items.each do |col1, col2|
          # handle multiple lines in the second column
          col2 = indent(col2.to_s, ' ' * indent_size).lstrip

          line = "%-#{indent_size}s%s" % [col1, col2]
          line.strip!
          puts line
        end
      end

      def section(label, &block)
        puts unless first_print?
        heading(label)

        sub_builder = TextBuilder.new(@richtext)
        yield(sub_builder) if block_given?
        puts indent(sub_builder.string)
      end

      def indent(content, indentation = nil)
        indentation ||= " " * INDENT_STEP
        content = content.split("\n") unless content.is_a? Array
        content.map do |line|
          (indentation + line).rstrip
        end.join("\n")
      end

      protected

      def heading(label)
        label = "#{label}:"
        label = HighLine.color(label, :bold) if @richtext
        puts label
      end

      def puts(*args)
        @out.puts(*args)
      end

      def first_print?
        @out.size == 0
      end

      def normalize_list(items)
        items.map do |i|
          i.is_a?(Array) ? i : [i]
        end
      end
    end
  end
end
