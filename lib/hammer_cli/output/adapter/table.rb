require 'table_print'
require File.join(File.dirname(__FILE__), 'wrapper_formatter')

module HammerCLI::Output::Adapter

  class Table < Abstract

    MAX_COLUMN_WIDTH = 80
    MIN_COLUMN_WIDTH = 5

    def tags
      [:screen, :flat]
    end

    def print_record(fields, record)
      print_collection(fields, [record].flatten(1))
    end

    def print_collection(all_fields, collection)
      fields = field_filter.filter(all_fields)

      rows = collection.collect do |d|
        row = {}
        fields.each do |f|
          row[label_for(f)] = WrapperFormatter.new(
            @formatters.formatter_for_type(f.class), f.parameters).format(data_for_field(f, d) || "")
        end
        row
      end

      if rows.empty?
        keys = fields.map { |f| [label_for(f), ''] }
        rows = [Hash[keys]]
        @header_only = true
      end

      options = fields.collect do |f|
        { label_for(f) => {
            :width => max_width_for(f)
          }
        }
      end

      sort_order = fields.map { |f| f.label.upcase }

      printer = TablePrint::Printer.new(rows, options)
      TablePrint::Config.max_width = MAX_COLUMN_WIDTH
      TablePrint::Config.multibyte = true

      output = sort_columns(printer.table_print, sort_order)
      dashes = /\n([-|]+)\n/.match(output)

      if @header_only
        output = output.lines.first
      end

      puts dashes[1] if dashes
      puts output
      puts dashes[1] if dashes

      if collection.meta.pagination_set? && collection.count < collection.meta.subtotal
        pages = (collection.meta.subtotal.to_f/collection.meta.per_page).ceil
        puts _("Page %{page} of %{total} (use --page and --per-page for navigation)") % {:page => collection.meta.page, :total => pages}
      end
    end

    protected

    def field_filter
      filtered = [Fields::ContainerField]
      filtered << Fields::Id unless @context[:show_ids]
      HammerCLI::Output::FieldFilter.new(filtered)
    end

    private

    def label_for(field)
      width = width_for(field)
      if width
        "%-#{width}s" % field.label.to_s
      else
        field.label.to_s
      end
    end

    def max_width_for(field)
      width = width_for(field)
      width ||= field.parameters[:max_width]
      width = MIN_COLUMN_WIDTH if width && width < MIN_COLUMN_WIDTH
      width
    end

    def width_for(field)
      width = field.parameters[:width]
      width = MIN_COLUMN_WIDTH if width && width < MIN_COLUMN_WIDTH
      width
    end


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
