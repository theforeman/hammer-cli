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
      fields_col_size = max_label_length || _('Fields').size
      fields_col = normalize_column(fields_col_size, _('Fields'), centralize: true)
      fields_col += ' ' unless (fields_col_size - fields_col.size).zero?
      header_bits = [fields_col]
      hline_bits = ['-' * fields_col_size]
      field_sets.map do |set|
        header_bits << normalize_column(set.size, set)
        hline_bits << '-' * set.size
      end
      rows_bits = fields_row(@fields, field_sets, fields_col_size)
      line = "+-#{hline_bits.join('-+-')}-+\n"
      table = line
      table += "| #{header_bits.join(' | ')} |\n"
      table += line
      table += "#{rows_bits.join("\n")}\n"
      table += line
      table
    end

    private

    def max_label_length
      field_labels(@fields, full_labels: true).map(&:size).max
    end

    def normalize_column(width, col, centralize: false)
      padding = width - HammerCLI::Output::Utils.real_length(col)
      if padding >= 0
        if centralize
          padding /= 2
          col.prepend(' ' * padding)
        end
        col += (' ' * padding)
      else
        col, real_len = HammerCLI::Output::Utils.real_truncate(col, width - 3)
        col += '...'
        col += ' ' if real_len < (width - 3)
      end
      col
    end

    def fields_row(fields, sets, fields_col_size)
      fields.each_with_object([]) do |field, rows|
        next rows << fields_row(field.fields, sets, fields_col_size) if field.respond_to?(:fields)

        row = [normalize_column(fields_col_size, field.full_label)]
        sets.each do |set|
          mark = field.sets.include?(set) ? 'x' : ' '
          column = normalize_column(set.size, mark, centralize: true)
          column += ' ' unless (set.size - column.size).zero?
          row << column
        end
        rows << "| #{row.join(' | ')} |"
      end
    end

    def field_labels(fields, full_labels: false)
      fields.each_with_object([]) do |field, labels|
        label = full_labels ? field.full_label : field.label
        next labels << label unless field.respond_to?(:fields)

        labels.concat(field_labels(field.fields, full_labels: full_labels))
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
