require File.join(File.dirname(__FILE__), 'wrapper_formatter')

module HammerCLI::Output::Adapter
  class Table < Abstract
    def initialize(context = {}, formatters = {}, filters = {})
      super
      @printed = 0
    end

    def features
      return %i[rich_text serialized inline] if tags.empty?

      tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
    end

    def print_record(fields, record)
      print_collection(fields, [record].flatten(1))
    end

    def print_collection(all_fields, collection, options = {})
      current_chunk = options[:current_chunk] || :single
      fields = filter_fields(all_fields).filter_by_classes
                                        .filter_by_sets
                                        .filter_by_data(collection.first,
                                                        compact_only: true)
                                        .filtered_fields
      formatted_collection = format_values(fields, collection)

      columns = fields.each_with_object({}) do |field, result|
        result[field.label] = field.parameters
      end

      table_gen = HammerCLI::Output::Generators::Table.new(
        columns, formatted_collection, no_headers: @context[:no_headers]
      )

      meta = collection.respond_to?(:meta) ? collection.meta : nil

      output_stream.print(table_gen.header) if %i[first single].include?(current_chunk)

      output_stream.print(table_gen.body)

      @printed += collection.count

      # print closing line only after the last chunk
      output_stream.print(table_gen.footer) if %i[last single].include?(current_chunk)

      return unless meta && meta.pagination_set?

      leftovers = %i[last single].include?(current_chunk) && @printed < meta.subtotal
      if @context[:verbosity] >= meta.pagination_verbosity &&
         collection.count < meta.subtotal &&
         leftovers
        pages = (meta.subtotal.to_f / meta.per_page).ceil
        puts _("Page %{page} of %{total} (use --page and --per-page for navigation).") % {:page => meta.page, :total => pages}
      end
    end

    protected

    def classes_filter
      super << Fields::ContainerField
    end

    def format_values(fields, collection)
      collection.collect do |d|
        fields.inject({}) do |row, f|
          formatter = WrapperFormatter.new(@formatters.formatter_for_type(f.class), f.parameters)
          row.update(f.label => formatter.format(data_for_field(f, d)).to_s)
        end
      end
    end
  end

  HammerCLI::Output::Output.register_adapter(:table, Table)
end
