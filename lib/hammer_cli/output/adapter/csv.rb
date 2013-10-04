require 'csv'
if CSV.const_defined? :Reader
  # Ruby 1.8 compatible
  require 'fastercsv'
  Object.send(:remove_const, :CSV)
  CSV = FasterCSV
else
  # CSV is now FasterCSV in ruby 1.9
end

module HammerCLI::Output::Adapter

  class CSValues < Abstract

    def tags
      [:flat]
    end

    def print_records(fields, data)
      csv_string = CSV.generate(
          :col_sep => @context[:csv_separator] || ',', 
          :encoding => 'utf-8') do |csv|
        # labels
        csv << fields.select{ |f| !(f.class <= Fields::Id) || @context[:show_ids] }.map { |f| f.label }
        # data
        data.each do |d|
          csv << fields.inject([]) do |row, f| 
            unless f.class <= Fields::Id && !@context[:show_ids]
              value = (f.get_value(d) || '')
              formatter = @formatters.formatter_for_type(f.class)
              row << (formatter ? formatter.format(value) : value)
            end
            row
          end
        end
      end
      puts csv_string
    end
  end

  HammerCLI::Output::Output.register_adapter(:csv, CSValues)

end
