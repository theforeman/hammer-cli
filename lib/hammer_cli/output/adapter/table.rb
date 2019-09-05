require File.join(File.dirname(__FILE__), 'wrapper_formatter')

module HammerCLI::Output::Adapter
  class Table < Abstract
    def features
      return %i[rich_text serialized inline] if tags.empty?

      tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
    end

    def print_record(fields, record)
      print_collection(fields, [record].flatten(1))
    end

    def print_collection(all_fields, collection)
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
      output_stream.print(table_gen.result)

      if collection.respond_to?(:meta) && collection.meta.pagination_set? &&
         @context[:verbosity] >= collection.meta.pagination_verbosity &&
         collection.count < collection.meta.subtotal
        pages = (collection.meta.subtotal.to_f / collection.meta.per_page).ceil
        puts _("Page %{page} of %{total} (use --page and --per-page for navigation).") % {:page => collection.meta.page, :total => pages}
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
          row.update(f.label => formatter.format(data_for_field(f, d) || "").to_s)
        end
      end
    end
  end

  HammerCLI::Output::Output.register_adapter(:table, Table)
end
