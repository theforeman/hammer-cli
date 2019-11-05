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

    def update_field_sets(set_names, field_ids)
      set_names = [set_names] unless set_names.is_a?(Array)
      field_ids = [field_ids] unless field_ids.is_a?(Array)
      field_ids.each do |field_id|
        find_field(field_id).sets = find_field(field_id).sets.concat(set_names).uniq
      end
    end

    def insert(mode, field_id, fields = nil, &block)
      definition = self.class.new
      definition.append(fields, &block)
      HammerCLI.insert_relative(@fields, mode, field_index(field_id), *definition.fields)
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

    def field_sets
      nested_fields_sets(@fields).uniq.sort
    end

    def sets_table
      columns = field_sets.unshift(_('Fields'))
      data = fields_data(@fields, columns).flatten
      table_gen = HammerCLI::Output::Generators::Table.new(columns, data)
      table_gen.result
    end

    private

    def fields_data(fields, sets)
      fields.each_with_object([]) do |field, data|
        next data << fields_data(field.fields, sets) if field.respond_to?(:fields)

        data << sets.each_with_object({}) do |set, res|
          mark = field.sets.include?(set) ? 'x' : ''
          value = set == sets.first ? field.full_label : mark
          res.update(set => value)
        end
      end
    end

    def nested_fields_sets(fields)
      fields.map do |field|
        next field.sets unless field.respond_to?(:fields)

        nested_fields_sets(field.fields)
      end.flatten
    end

    def field_index(field_id)
      index = @fields.find_index do |f|
        f.match_id?(field_id)
      end
      raise ArgumentError, "Field #{field_id} not found" if index.nil?
      index
    end
  end
end
