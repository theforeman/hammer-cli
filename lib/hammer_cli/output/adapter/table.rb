require File.join(File.dirname(__FILE__), 'wrapper_formatter')
require 'hammer_cli/output/utils'

module HammerCLI::Output::Adapter

  class Table < Abstract

    MAX_COLUMN_WIDTH = 80
    MIN_COLUMN_WIDTH = 5

    HLINE = '-'
    LINE_SEPARATOR = '-|-'
    COLUMN_SEPARATOR = ' | '

    def tags
      [:screen, :flat]
    end

    def print_record(fields, record)
      print_collection(fields, [record].flatten(1))
    end

    def print_collection(all_fields, collection)
      fields = field_filter.filter(all_fields)

      formatted_collection = format_values(fields, collection)
      # calculate hash of column widths (label -> width)
      widths = calculate_widths(fields, formatted_collection)

      header_bits = []
      hline_bits = []
      fields.map do |f|
        header_bits << normalize_column(widths[f.label], f.label.upcase)
        hline_bits << HLINE * widths[f.label]
      end

      line = hline_bits.join(LINE_SEPARATOR)
      unless @context[:no_headers]
        output_stream.puts line
        output_stream.puts header_bits.join(COLUMN_SEPARATOR)
        output_stream.puts line
      end

      formatted_collection.collect do |row|
        row_bits = fields.map do |f|
          normalize_column(widths[f.label], row[f.label] || "")
        end
        output_stream.puts row_bits.join(COLUMN_SEPARATOR)
      end

      # print closing line only when the table isn't empty
      # and there is no --no-headers option
      output_stream.puts line unless formatted_collection.empty? || @context[:no_headers]

      if collection.meta.pagination_set? && collection.count < collection.meta.subtotal
        pages = (collection.meta.subtotal.to_f/collection.meta.per_page).ceil
        puts _("Page %{page} of %{total} (use --page and --per-page for navigation).") % {:page => collection.meta.page, :total => pages}
      end
    end

    protected

    def normalize_column(width, value)
      value = value.to_s
      padding = width - HammerCLI::Output::Utils.real_length(value)
      if padding >= 0
        value += (" " * padding)
      else
        value, real_length = HammerCLI::Output::Utils.real_truncate(value, width-3)
        value += '...'
        value += ' ' if real_length < (width - 3)
      end
      value
    end

    def format_values(fields, collection)
      collection.collect do |d|
        fields.inject({}) do |row, f|
          formatter = WrapperFormatter.new(@formatters.formatter_for_type(f.class), f.parameters)
          row.update(f.label => formatter.format(data_for_field(f, d) || "").to_s)
        end
      end
    end

    def calculate_widths(fields, collection)
      Hash[fields.map { |f| [f.label, calculate_column_width(f, collection)] }]
    end

    def calculate_column_width(field, collection)
      if field.parameters[:width]
        return [field.parameters[:width], MIN_COLUMN_WIDTH].max
      end

      width = HammerCLI::Output::Utils.real_length(field.label.to_s)
      max_width = max_width_for(field)
      collection.each do |item|
        width = [HammerCLI::Output::Utils.real_length(item[field.label]), width].max
        return max_width if width >= max_width
      end
      width
    end

    def field_filter
      filtered = [Fields::ContainerField]
      filtered << Fields::Id unless @context[:show_ids]
      HammerCLI::Output::FieldFilter.new(filtered)
    end

    private

    def max_width_for(field)
      if field.parameters[:max_width]
        [field.parameters[:max_width], MAX_COLUMN_WIDTH].min
      else
        MAX_COLUMN_WIDTH
      end
    end
  end

  HammerCLI::Output::Output.register_adapter(:table, Table)
end
