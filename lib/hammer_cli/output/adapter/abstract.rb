module HammerCLI::Output::Adapter

  class Abstract

    def tags
      %i[]
    end

    def features
      return %i[] if tags.empty?

      tags.map { |t| HammerCLI::Output::Utils.tag_to_feature(t) }
    end

    def initialize(context={}, formatters={}, filters = {})
      context[:verbosity] ||= HammerCLI::V_VERBOSE
      @context = context
      @formatters = HammerCLI::Output::Formatters::FormatterLibrary.new(filter_formatters(formatters))
      @paginate_by_default = true
      @filters = filters
    end

    def paginate_by_default?
      !!@paginate_by_default
    end

    def print_message(msg, msg_params={})
      puts msg.format(msg_params)
    end

    def print_error(msg, details=nil, msg_params={})
      details = details.split("\n") if details.kind_of? String

      if details
        indent = "  "
        msg += ":\n"
        msg += indent + details.join("\n"+indent)
      end

      $stderr.puts msg.format(msg_params)
    end

    def print_record(fields, record)
      raise NotImplementedError
    end

    def print_collection(fields, collection)
      raise NotImplementedError
    end

    def reset_context
      @context.delete(:fields)
    end

    protected

    def filter_fields(fields)
      HammerCLI::Output::FieldFilter.new(fields, field_filters)
    end

    def self.data_for_field(field, record)
      path = field.path

      path.inject(record) do |record, path_key|
        return nil unless record && record.is_a?(Hash)
        if record.key?(path_key.to_sym)
          record[path_key.to_sym]
        elsif record.key?(path_key.to_s)
          record[path_key.to_s]
        else
          HammerCLI::Output::DataMissing.new
        end
      end
    end

    def data_for_field(field, record)
      Abstract.data_for_field(field, record)
    end

    def output_stream
      return @context[:output_file] if @context.has_key?(:output_file)
      $stdout
    end

    def field_filters
      {
        classes_filter: classes_filter,
        sets_filter: sets_filter
      }.merge(@filters) do |_, old_filter, new_filter|
        old_filter + new_filter
      end
    end

    def classes_filter
      return [] if @context[:show_ids]

      [Fields::Id]
    end

    def sets_filter
      @context[:fields] || ['DEFAULT']
    end

    private

    def filter_formatters(formatters_map)
      formatters_map ||= {}
      formatters_map.inject({}) do |map, (type, formatter_list)|
        # remove incompatible formatters
        filtered = formatter_list.select { |f| f.match?(features) }
        # put serializers first
        map[type] = filtered.sort_by { |f| f.required_features.include?(:serialized) ? 0 : 1 }
        map
      end
    end
  end
end
