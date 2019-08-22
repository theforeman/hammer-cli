require 'hammer_cli/help/definition'

module HammerCLI
  module Help
    class TextBuilder
      attr_accessor :definition

      def initialize(richtext = false)
        @richtext = richtext
        @definition = HammerCLI::Help::Definition.new
      end

      def string
        @definition.build_string
      end

      def text(content, options = {})
        @definition << HammerCLI::Help::Text.new(content, options)
      end

      def note(content, options = {})
        @definition << HammerCLI::Help::Note.new(content, options)
      end

      def list(items, options = {}, &block)
        return if items.empty?

        @definition << HammerCLI::Help::List.new(items, options, &block)
      end

      def section(label, options = {}, &block)
        sub_builder = TextBuilder.new(@richtext)
        yield(sub_builder) if block_given?
        options[:richtext] ||= @richtext
        @definition << HammerCLI::Help::Section.new(label, sub_builder.definition, options)
      end

      def find_item(item_id)
        @definition.find_item(item_id)
      end

      def at(path = [])
        item = path.empty? ? self : @definition.at(path)
        sub_builder = TextBuilder.new(@richtext)
        sub_builder.definition = item.definition
        yield(sub_builder)
        item.definition = sub_builder.definition
      end

      def insert(mode, item_id)
        sub_builder = TextBuilder.new(@richtext)
        yield(sub_builder)
        @definition.insert_definition(mode, item_id, sub_builder.definition)
      end

      def indent(content, indentation = nil)
        HammerCLI::Help::AbstractItem.indent(content, indentation)
      end
    end
  end
end
