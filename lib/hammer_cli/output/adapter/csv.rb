require 'csv'
if CSV.const_defined? :Reader
  # Ruby 1.8 compatible
  require 'fastercsv'
  Object.send(:remove_const, :CSV)
  CSV = FasterCSV
else
  # CSV is now FasterCSV in ruby 1.9
end

require File.join(File.dirname(__FILE__), 'wrapper_formatter')

module HammerCLI::Output::Adapter

  class CSValues < Abstract

    class Cell
      attr_accessor :field_wrapper, :data

      def initialize(field_wrapper, data, formatters)
        @field_wrapper = field_wrapper
        @data = data
        @formatters = formatters
      end

      def self.create_cells(field_wrappers, data, formatters)
        results = []
        field_wrappers.each do |field_wrapper|
          field = field_wrapper.field
          if field.is_a? Fields::Collection
            results = results + expand_collection(field, data, formatters)
          elsif field.is_a?(Fields::ContainerField)
            results = results + expand_container(field, data, formatters)
          else
            results << Cell.new(field_wrapper, data, formatters)
          end
        end
        return results
      end

      def formatted_value
        WrapperFormatter.new(
            @formatters.formatter_for_type(@field_wrapper.field.class),
            @field_wrapper.field.parameters).format(value)
      end

      def self.values(headers, cells)
        headers.map do |header|
          cell = cells.find { |cell| cell.in_column?(header) }
          cell ? cell.formatted_value : ''
        end
      end

      def self.headers(cells, context)
        cells.map(&:field_wrapper).select { |fw| ! fw.is_id? ||
          context[:show_ids] }.map(&:display_name)
      end

      def in_column?(header)
        self.field_wrapper.display_name == header
      end

      private

      def self.expand_collection(field, data, formatters)
        results = []
        collection_data = data_for_field(field, data) || []
        collection_data.each_with_index do |child_data, i|
          field.fields.each do |child_field|
            child_field_wrapper = FieldWrapper.new(child_field)
            child_field_wrapper.append_prefix(field.label)
            child_field_wrapper.append_suffix((i + 1).to_s)
            results << Cell.new(child_field_wrapper, collection_data[i] || {}, formatters)
          end
        end
        results
      end

      def self.expand_container(field, data, formatters)
        child_fields = FieldWrapper.wrap(field.fields)
        child_fields.each{ |child| child.append_prefix(field.label) }
        create_cells(child_fields, data_for_field(field, data), formatters)
      end

      def self.data_for_field(field, data)
        HammerCLI::Output::Adapter::CSValues.data_for_field(field, data)
      end

      def value
        Cell.data_for_field(@field_wrapper.field, data)
      end
    end

    class FieldWrapper
      attr_accessor :name, :field

      def self.wrap(fields)
        fields.map{ |f| FieldWrapper.new(f) }
      end

      def initialize(field)
        @field = field
        @name = nil
        @prefixes = []
        @suffixes = []
        @data
      end

      def append_suffix(suffix)
        @suffixes << suffix
      end

      def append_prefix(prefix)
        @prefixes << prefix
      end

      def prefix
        @prefixes.join("::")
      end

      def suffix
        @suffixes.join("::")
      end

      def display_name
        names = []
        names << prefix unless prefix.empty?
        names << @field.label if @field.label
        names << suffix unless suffix.empty?
        names.join("::")
      end

      def is_id?
        self.field.class <= Fields::Id
      end
    end

    def tags
      [:flat]
    end

    def paginate_by_default?
      false
    end

    def row_data(fields, collection)
      result = []
      collection.each do |data|
        result << Cell.create_cells(FieldWrapper.wrap(fields), data, @formatters)
      end
      result
    end

    def print_record(fields, record)
      print_collection(fields, [record].flatten(1))
    end

    def print_collection(fields, collection)
      rows = row_data(fields, collection)
      # get headers using columns heuristic
      headers = rows.map{ |r| Cell.headers(r, @context) }.max_by{ |headers| headers.size }
      # or use headers from output definition
      headers ||= default_headers(fields)
      csv_string = generate do |csv|
        csv << headers if headers
        rows.each do |row|
          csv << Cell.values(headers, row)
        end
      end
      puts csv_string
    end

    def print_message(msg, msg_params={})
      csv_string = generate do |csv|
        id = msg_params["id"] || msg_params[:id]
        name = msg_params["name"] || msg_params[:name]

        labels = [_("Message")]
        data = [msg.format(msg_params)]

        if id
          labels << _("Id")
          data << id
        end

        if name
          labels << _("Name")
          data << name
        end

        csv << labels
        csv << data
      end
      puts csv_string
    end

    private

    def generate(&block)
      CSV.generate(
        :col_sep => @context[:csv_separator] || ',',
        :encoding => 'utf-8',
        &block
      )
    end

    def default_headers(fields)
      fields.select{ |f| !(f.class <= Fields::Id) || @context[:show_ids] }.map { |f| f.label }
    end

  end

  HammerCLI::Output::Output.register_adapter(:csv, CSValues)

end
