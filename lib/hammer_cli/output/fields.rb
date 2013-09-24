require 'hammer_cli/output/dsl'

module Fields

  class Field

    def initialize(options={})
    end

    def get_value(data)
    end

  end

  class LabeledField < Field

    attr_reader :label

    def initialize(options={})
      @label = options[:label]
    end
  end

  class DataField < LabeledField

    attr_reader :path

    def initialize(options={})
      @path = options[:path] || []
      super(options)
    end

    def get_value(data)
      follow_path(data, path || [])
    end

    private

    def follow_path(record, path)
      record = symbolize_hash_keys(record)

      path.inject(record) do |record, path_key|
        if record.has_key? path_key.to_sym
          record[path_key.to_sym]
        else
          return nil
        end
      end
    end

    def symbolize_hash_keys(h)
      if h.is_a? Hash
        return h.inject({}){|result,(k,v)| result.update k.to_sym => symbolize_hash_keys(v)}
      elsif h.is_a? Array
        return h.collect{|item| symbolize_hash_keys(item)}
      else
        h
      end
    end

  end

  class Date < DataField
  end

  class Id < DataField
  end

  class List < DataField
  end

  class KeyValue < DataField
  end


  class Joint < DataField
    def initialize(options={}, &block)
      super(options)
      @attributes = options[:attributes] || []
    end

    attr_reader :attributes
  end

  class Label < LabeledField

    def initialize(options={}, &block)
      super(options)
      dsl = HammerCLI::Output::Dsl.new :path => options[:path]
      dsl.build &block if block_given?

      self.output_definition.append dsl.fields
    end

    def output_definition
      @output_definition ||= HammerCLI::Output::Definition.new
      @output_definition
    end

  end

  class Collection < DataField

    def initialize(options={}, &block)
      super(options)
      dsl = HammerCLI::Output::Dsl.new
      dsl.build &block if block_given?

      self.output_definition.append dsl.fields
    end

    def output_definition
      @output_definition ||= HammerCLI::Output::Definition.new
      @output_definition
    end

  end

end
