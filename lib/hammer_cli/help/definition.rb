require_relative 'definition/abstract_item'
require_relative 'definition/text'
require_relative 'definition/list'
require_relative 'definition/section'

module HammerCLI
  module Help
    class Definition < Array
      def build_string
        @out = StringIO.new
        each do |item|
          next unless item.is_a? AbstractItem
          @out.puts unless first_print?
          @out.puts item.build_string
        end
        @out.string
      end

      def find_item(item_id)
        self[item_index(item_id)]
      end

      def at(path)
        return super(path) if path.is_a? Integer
        return self if path.empty?
        expand_path(path)
      end

      def insert_definition(mode, item_id, definition)
        HammerCLI.insert_relative(self, mode, item_index(item_id), *definition)
      end

      private

      def expand_path(path)
        path = [path] unless path.is_a? Array
        item = find_item(path[0])
        return item if path[1..-1].empty?
        item.definition.at(path[1..-1])
      end

      def first_print?
        @out.size.zero?
      end

      def item_index(item_id)
        index = find_index do |item|
          item.id == item_id
        end
        raise ArgumentError, "Help item '#{item_id}' not found" if index.nil?
        index
      end
    end
  end
end
