require 'hammer_cli/output/utils'

module HammerCLI
  module Output
    module Generators
      class Table
        class Column
          attr_reader :label, :params

          def initialize(label, params = nil)
            @label = label.to_s
            @params = params || {}
          end
        end

        MAX_COLUMN_WIDTH = 80
        MIN_COLUMN_WIDTH = 5

        HLINE = '-'
        LINE_SEPARATOR = '-|-'
        COLUMN_SEPARATOR = ' | '

        attr_reader :header, :body, :footer, :result

        def initialize(columns, data, options = {})
          @columns = columns.map { |label, params| Column.new(label, params) }
          @data = data
          @options = options
          create_table
        end

        private

        def create_header(header_bits, line)
          result = StringIO.new
          unless @options[:no_headers]
            result.puts(line)
            result.puts(header_bits.join(COLUMN_SEPARATOR))
            result.puts(line)
          end
          result.string
        end

        def create_body(widths)
          result = StringIO.new
          @data.collect do |row|
            row_bits = @columns.map do |col|
              normalize_column(widths[col.label], row[col.label] || '')
            end
            result.puts(row_bits.join(COLUMN_SEPARATOR))
          end
          result.string
        end

        def create_footer(line)
          result = StringIO.new
          result.puts(line) unless @data.empty? || @options[:no_headers]
          result.string
        end

        def create_result
          result = StringIO.new
          result.print(@header, @body, @footer)
          result.string
        end

        def create_table
          widths = calculate_widths(@columns, @data)
          header_bits = []
          hline_bits = []
          @columns.map do |col|
            header_bits << normalize_column(widths[col.label], col.label.upcase)
            hline_bits << HLINE * widths[col.label]
          end
          line = hline_bits.join(LINE_SEPARATOR)
          @header = create_header(header_bits, line)
          @body = create_body(widths)
          @footer = create_footer(line)
          @result = create_result
        end

        def normalize_column(width, value)
          value = value.to_s
          padding = width - HammerCLI::Output::Utils.real_length(value)
          if padding >= 0
            value += (' ' * padding)
          else
            value, real_length = HammerCLI::Output::Utils.real_truncate(value, width - 3)
            value += '...'
            value += ' ' if real_length < (width - 3)
          end
          value
        end

        def calculate_widths(columns, data)
          Hash[columns.map { |c| [c.label, calculate_column_width(c, data)] }]
        end

        def calculate_column_width(column, data)
          if column.params[:width]
            return [column.params[:width], MIN_COLUMN_WIDTH].max
          end

          width = HammerCLI::Output::Utils.real_length(column.label)
          max_width = max_width_for(column)
          data.each do |item|
            width = [HammerCLI::Output::Utils.real_length(item[column.label]), width].max
            return max_width if width >= max_width
          end
          width
        end

        def max_width_for(column)
          if column.params[:max_width]
            [column.params[:max_width], MAX_COLUMN_WIDTH].min
          else
            MAX_COLUMN_WIDTH
          end
        end
      end
    end
  end
end
