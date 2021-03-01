module HammerCLI::Output
  class FieldFilter
    attr_reader :fields, :filtered_fields
    attr_accessor :classes_filter, :sets_filter

    def initialize(fields = [], filters = {})
      self.fields = fields
      @classes_filter = filters[:classes_filter] || []
      @sets_filter = filters[:sets_filter] || []
    end

    def fields=(fields)
      @fields = fields || []
      @filtered_fields = @fields.dup
    end

    def filter_by_classes(classes = nil)
      classes ||= @classes_filter
      classes.each do |cls|
        @filtered_fields.reject! do |f|
          f.is_a? cls
        end
      end
      self
    end

    def filter_by_sets(sets = nil)
      sets ||= @sets_filter
      return self if sets.empty?

      set_names, labels = resolve_set_names(sets)
      deep_filter(@filtered_fields, set_names, labels)
      self
    end

    def filter_by_data(data, compact_only: false)
      @filtered_fields = displayable_fields(@filtered_fields,
                                            data,
                                            compact_only: compact_only)
      self
    end

    private

    def deep_filter(fields, set_names, labels)
      fields.select! do |f|
        allowed = include_by_label?(labels, f.full_label.downcase)
        allowed ||= (f.sets & set_names).any?
        deep_filter(f.fields, set_names, labels) if f.respond_to?(:fields)
        allowed
      end
    end

    def displayable_fields(fields, record, compact_only: false)
      fields.select do |field|
        field_data = HammerCLI::Output::Adapter::Abstract.data_for_field(
          field, record
        )
        if compact_only && !field_data.is_a?(HammerCLI::Output::DataMissing)
          true
        else
          field.display?(field_data)
        end
      end
    end

    def include_by_label?(labels, label)
      labels.any? do |l|
        l.start_with?("#{label}/") || label.match(%r{^#{l.gsub(/\*/, '.*')}(|\/.*)$}) || l == label
      end
    end

    def resolve_set_names(sets)
      set_names = []
      labels = []
      sets.each do |name|
        next set_names << name if name.upcase == name

        labels << name.downcase
      end
      [set_names, labels]
    end
  end
end
