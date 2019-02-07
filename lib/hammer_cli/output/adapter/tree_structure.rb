module HammerCLI::Output::Adapter
  class TreeStructure < Abstract

    def initialize(context={}, formatters={})
      super
      @paginate_by_default = false
    end

    def tags
      [:tree_structure, :data]
    end

    def prepare_collection(fields, collection)
      collection.map do |element|
        render_fields(fields, element)
      end
    end

    def prepare_message(msg, msg_params = {})
      data = {
        capitalize(:message) => msg.format(msg_params)
      }
      return data if msg_params.nil?

      id = msg_params['id'] || msg_params[:id]
      name = msg_params['name'] || msg_params[:name]

      data[capitalize(:id)] = id unless id.nil?
      data[capitalize(:name)] = name unless name.nil?
      data
    end

    protected

    def field_filter
      filtered = []
      filtered << Fields::Id unless @context[:show_ids]
      HammerCLI::Output::FieldFilter.new(filtered)
    end

    def render_fields(fields, data)
      fields = field_filter.filter(fields)
      fields = displayable_fields(fields, data)
      fields.reduce({}) do |hash, field|
        field_data = data_for_field(field, data)
        next unless field.display?(field_data)
        hash.update(capitalize(field.label) => render_field(field, field_data))
      end
    end

    def render_field(field, data)
      if field.is_a? Fields::ContainerField
        data = [data] unless data.is_a? Array
        fields_data = data.map do |d|
          render_fields(field.fields, d)
        end
        render_data(field, map_data(fields_data))
      else
        formatter = @formatters.formatter_for_type(field.class)
        parameters = field.parameters
        parameters[:context] = @context
        if formatter
          data = formatter.format(data, field.parameters)
        end

        return data unless data.is_a?(Hash)
        data.transform_keys { |key| capitalize(key) }
      end
    end

    def render_data(field, data)
      data = data.map! { |d| d.transform_keys { |key| capitalize(key) } if d.is_a?(Hash) }
      if field.is_a?(Fields::Collection)
        if field.parameters[:numbered]
          numbered_data(data)
        else
          data
        end
      else
        data.first
      end
    end

    def map_data(data)
      if data.any? { |d| d.key?(nil) }
        data.map! { |d| d.values.first }
      end
      data
    end

    def numbered_data(data)
      i = 0
      data.inject({}) do |hash, value|
        i += 1
        hash.merge(i => value)
      end
    end

    def capitalize(string)
      capitalization = @context[:capitalization]
      return string if capitalization.nil?
      string.send(@context[:capitalization]) unless string.nil?
    end
  end
end
