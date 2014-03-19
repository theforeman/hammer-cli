module HammerCLI::Output::Adapter
  class Base < Abstract

    GROUP_INDENT = " "*4
    LABEL_DIVIDER = ": "

    def tags
      [:flat, :screen]
    end

    def print_record(fields, record)
      print_collection(fields, [record].flatten(1))
    end

    def print_collection(fields, collection)
      collection.each do |data|
        puts render_fields(fields, data)
        puts
      end
    end

    protected

    def field_filter
      filtered = []
      filtered << Fields::Id unless @context[:show_ids]
      HammerCLI::Output::FieldFilter.new(filtered)
    end

    def filter_fields(fields, data)
      field_filter.filter(fields).reject do |field|
        field_data = data_for_field(field, data)
        not field.display?(field_data)
      end
    end

    def render_fields(fields, data)
      output = ""

      fields = filter_fields(fields, data)

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
          fields_output = fields_output.sub(/^[ ]{4}/, " %-3s" % "#{idx})") if field.is_a? Fields::Collection

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
      data = formatter.format(data) if formatter
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
