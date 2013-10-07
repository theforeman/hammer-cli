module HammerCLI::Output::Adapter
  class Base < Abstract

    GROUP_INDENT = " "*2
    LABEL_DIVIDER = ": "

    def tags
      [:flat, :screen]
    end

    def print_records(fields, data)
      self.fields = fields

      data.each do |d|
        fields.collect do |f|
          render_field(f, d)
        end
        puts
      end
    end

    protected

    def render_Field(field, data, indent="")
      puts indent.to_s+" "+format_value(field, data).to_s
    end

    def render_Label(field, data, indent="")
      render_label(field, indent)
      puts
      indent = indent.to_s + GROUP_INDENT

      field.output_definition.fields.collect do |f|
        render_field(f, data, indent)
      end
    end

    def render_LabeledField(field, data, indent="")
      render_label(field, indent)
      puts format_value(field, data).to_s
    end

    def render_KeyValue(field, data, indent="")
      render_label(field, indent)
      params = field.get_value(data) || []
      print "%{name} => %{value}" % params
    end

    def render_Collection(field, data, indent="")
      render_label(field, indent)
      puts
      indent = indent.to_s + " "*(label_width_for_list(self.fields)+LABEL_DIVIDER.size)

      data = field.get_value(data) || []
      data.each do |d|
        field.output_definition.fields.collect do |f|
          render_field(f, d, indent)
        end
        puts
      end
    end

    def render_Joint(field, data, indent="")
      render_label(field, indent)
      data = field.get_value(data)
      puts field.attributes.collect{|attr| data[attr] }.join(" ")
    end

    def find_renderer(field)
      field.class.ancestors.each do |cls|
        render_method = "render_"+field_type(cls)
        return method(render_method) if respond_to?(render_method, true)
      end
      raise "No renderer found for field %s" % field.class
    end

    def render_field(field, data, indent="")
      renderer = find_renderer(field)
      renderer.call(field, data, indent)
    end

    def render_label(field, indent="")
      if field.label
        w = label_width_for_list(self.fields) - indent.size + 1
        print indent.to_s+"%#{-w}s" % (field.label.to_s+LABEL_DIVIDER)
      else
        print indent.to_s
      end
    end

    def format_value(field, data)
      format_method = "format_"+field_type(field.class)

      value = field.get_value(data)
      formatter = @formatters.formatter_for_type(field.class)
      value = formatter.format(value) if formatter
      value
    end

    def field_type(field_class)
      field_class.name.split("::")[-1]
    end

    def label_width_for(field)
      if field.respond_to?(:output_definition)
        label_width_for_list(field.output_definition.fields)+GROUP_INDENT.size
      elsif field.respond_to?(:label)
        field.label.size+LABEL_DIVIDER.size rescue 0
      else
        0
      end
    end

    def label_width_for_list(fields)
      fields.inject(0) do |result, f|
        width = label_width_for(f)
        (width > result) ? width : result
      end
    end

    attr_accessor :fields

  end

  HammerCLI::Output::Output.register_adapter(:base, Base)
end
