module HammerCLI::Output
  class Definition
    attr_accessor :fields

    def initialize
      @fields = []
    end

    def append(fields = nil, &block)
      fields = [fields].compact unless fields.is_a?(Array)
      @fields += fields
      return @fields unless block_given?
      dsl = Dsl.new
      dsl.build(&block)
      @fields += dsl.fields
    end

    def find_field(field_id)
      @fields[field_index(field_id)]
    end

    def insert(mode, field_id, fields = nil, &block)
      index = field_index(field_id)
      index += 1 if mode == :after
      definition = self.class.new
      definition.append(fields, &block)
      insert_fields(index, definition.fields, with_remove: mode == :replace)
    end

    def at(path = [])
      path = [path] unless path.is_a? Array
      return self if path.empty?

      field = find_field(path[0])

      unless field.respond_to?(:output_definition)
        raise ArgumentError, "Field #{path[0]} doesn't have nested output definition"
      end

      field.output_definition.at(path[1..-1])
    end

    def clear
      @fields = []
    end

    def empty?
      @fields.empty?
    end

    private

    def field_index(field_id)
      index = @fields.find_index do |f|
        f.match_id?(field_id)
      end
      raise ArgumentError, "Field #{field_id} not found" if index.nil?
      index
    end

    def insert_fields(index, fields, with_remove: false)
      @fields.delete_at(index) if with_remove
      fields.each_with_index do |f, i|
        @fields.insert(index + i, f)
      end
    end
  end
end
