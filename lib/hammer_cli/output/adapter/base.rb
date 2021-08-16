module HammerCLI::Output::Adapter
  class Base < Abstract

    GROUP_INDENT = " "*4
    LABEL_DIVIDER = ": "

    def features
      return %i[serialized rich_text multiline] if tags.empty?

      tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
    end

    def print_record(fields, record)
      print_collection(fields, [record].flatten(1))
    end

    def print_collection(fields, collection, options = {})
      collection.each do |data|
        output_stream.puts render_fields(fields, data)
        output_stream.puts
      end
    end

    protected

    def render_fields(fields, data)
      output = ''
      fields = filter_fields(fields).filter_by_classes
                                    .filter_by_sets
                                    .filter_by_data(data)
                                    .filtered_fields
      label_width = label_width(fields)

      fields.collect do |field|
        field_data = data_for_field(field, data)

        next unless field.display?(field_data)
        output += render_field(field, field_data, label_width)
        output += "\n"
      end
      output.rstrip
    end

    def render_field(field, data, label_width)
      if field.is_a? Fields::ContainerField
        output = ""

        idx = 0
        data = [data] unless data.is_a? Array
        data.each do |d|
          idx += 1
          fields_output = render_fields(field.fields, d).indent_with(GROUP_INDENT)
          if field.is_a?(Fields::Collection) && field.parameters[:numbered]
            fields_output = fields_output.sub(/^[ ]{4}/, " %-3s" % "#{idx})")
          end

          output += fields_output
          output += "\n"
        end

        render_label(field, label_width) + "\n" + output.rstrip
      else
        render_label(field, label_width) +
        render_value(field, data)
      end
    end

    def render_label(field, width)
      if field.label
        "%-#{width}s" % (field.label.to_s + LABEL_DIVIDER)
      else
        ""
      end
    end

    def render_value(field, data)
      formatter = @formatters.formatter_for_type(field.class)
      parameters = field.parameters
      parameters[:context] = context_for_fields
      data = formatter.format(data, field.parameters) if formatter
      data.to_s
    end

    def label_width(fields)
      fields.inject(0) do |result, f|
        width = f.label.to_s.size + LABEL_DIVIDER.size
        (width > result) ? width : result
      end
    end

  end

  HammerCLI::Output::Output.register_adapter(:base, Base)
end
