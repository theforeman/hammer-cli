require 'table_print'

module HammerCLI::Output::Adapter

  class Table < Base

    def print_records(fields, data)

      rows = data.collect do |d|
        row = {}
        fields.each do |f|
          row[f.label.to_sym] = f.get_value(d) || ""
        end
        row
      end

      options = fields.collect do |f|
        { f.label.to_sym => {
            :formatters => [ Formatter.new(self, "format_"+field_type(f.class)) ] } }
      end

      printer = TablePrint::Printer.new(rows, options)
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

  class Formatter
    def initialize(adapter, method)
      @adapter = adapter
      @method = method
    end

    def format(value)
      if @adapter.respond_to?(@method, true)
        value = @adapter.send(@method, value)
      end
      value
    end
  end

end
