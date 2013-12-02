require 'table_print'

module HammerCLI::Output::Adapter

  class Table < Abstract

    def tags
      [:screen, :flat]
    end

    def print_record(fields, record)
      print_collection(fields, [record].flatten(1))
    end

    def print_collection(fields, collection)

      rows = collection.collect do |d|
        row = {}
        fields.each do |f|

          row[f.label.to_sym] = f.get_value(d) || ""
        end
        row
      end

      options = fields.collect do |f|
        next if f.class <= Fields::Id && !@context[:show_ids]
        { f.label.to_sym => { :formatters => Array(@formatters.formatter_for_type(f.class)) } }
      end

      printer = TablePrint::Printer.new(rows, options)
      TablePrint::Config.max_width = 40

      output = printer.table_print
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

  end

  HammerCLI::Output::Output.register_adapter(:table, Table)

end
