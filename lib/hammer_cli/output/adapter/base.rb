module HammerCLI::Output::Adapter
  class Base < Abstract

    GROUP_INDENT = " "*2
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

    def render_fields(fields, data)
      output = ""

      label_width = label_width(fields)
      fields.collect do |f|
        output += render_field(f, data_for_field(f, data), label_width)
        output += "\n"
      end
      output.rstrip
    end

    def render_field(field, data, label_width)

      if field.is_a? Fields::ContainerField
        output = ""

        data = [data] unless data.is_a? Array
        data.each do |d|
          output += indent_lines(render_fields(field.fields, d))
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

    def indent_lines(lines)
      lines.gsub(/^/, GROUP_INDENT)
    end

  end

  HammerCLI::Output::Output.register_adapter(:base, Base)
end
