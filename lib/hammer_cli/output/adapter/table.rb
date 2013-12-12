require 'table_print'

module HammerCLI::Output::Adapter

  class Table < Abstract

    def tags
      [:screen, :flat]
    end

    def print_record(fields, record)
      print_collection(fields, [record].flatten(1))
    end

    def print_collection(all_fields, collection)

      fields = all_fields.reject { |f| f.class <= Fields::Id && !@context[:show_ids] }

      rows = collection.collect do |d|
        row = {}
        fields.each do |f|
          row[f.label.to_sym] = f.get_value(d) || ""
        end
        row
      end

      options = fields.collect do |f|
        { f.label.to_sym => { :formatters => Array(@formatters.formatter_for_type(f.class)) } }
      end

      sort_order = fields.map { |f| f.label.upcase }

      printer = TablePrint::Printer.new(rows, options)
      TablePrint::Config.max_width = 40

      output = sort_columns(printer.table_print, sort_order)
      dashes = /\n([-|]+)\n/.match(output)

      puts dashes[1] if dashes
      puts output
      puts dashes[1] if dashes
    end

    def print_heading(heading, size)
      size = heading.size if heading.size > size
      puts '-' * size
      puts ' ' * ((size-heading.size)/2) + heading
      puts '-' * size
    end

    private

    def sort_columns(output, sort_order)
      return output if sort_order.length == 1 # don't sort one column
      delimiter = ' | '
      lines = output.split("\n")
      out = []

      headers = lines.first.split(delimiter).map(&:strip)

      # create mapping table for column indexes
      sort_map = []
      sort_order.each { |c| sort_map << headers.index(c) }

      lines.each do |line|
        columns = line.split(delimiter)
        if columns.length == 1 # dashes
          columns = columns.first.split('-|-')
          if columns.length == 1
            out << columns.first
          else # new style dashes
            new_row = []
            sort_map.each { |i| new_row << columns[i] }
            out << new_row.join('-|-')
          end
        else
          # reorder row
          new_row = []
          sort_map.each { |i| new_row << columns[i] }
          out << new_row.join(delimiter)
        end
      end

      out.join("\n")
    end

  end

  HammerCLI::Output::Output.register_adapter(:table, Table)

end
