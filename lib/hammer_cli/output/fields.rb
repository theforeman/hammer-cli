require 'hammer_cli/output/dsl'

module Fields

  class Field

    attr_reader :label
    attr_reader :path

    def initialize(options={})
      @hide_blank = options[:hide_blank].nil? ? false : options[:hide_blank]
      @hide_missing = options[:hide_missing].nil? ? true : options[:hide_missing]
      @path = options[:path] || []
      @label = options[:label]
      @options = options
    end

    def hide_blank?
      @hide_blank
    end

    def hide_missing?
      @hide_missing
    end

    def display?(value)
      if value.is_a?(HammerCLI::Output::DataMissing)
        !hide_missing?
      elsif value.nil?
        !hide_blank?
      else
        true
      end
    end

    def parameters
      @options
    end

  end


  class ContainerField < Field

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

    def fields
      @output_definition.fields
    end

    def display?(value)
      if value.is_a?(HammerCLI::Output::DataMissing)
        !hide_missing?
      elsif value.nil? || value.empty?
        !hide_blank?
      else
        true
      end
    end
  end

  class Date < Field
  end

  class Id < Field
  end

  class List < Field
  end

  class LongText < Field
  end

  class KeyValue < Field
  end

  class Label < ContainerField

    def display?(value)
      return false if value.is_a?(HammerCLI::Output::DataMissing) && hide_missing?
      return true if not hide_blank?

      !(value.nil? || value.empty?) && fields.any? do |f|
        f.display?(HammerCLI::Output::Adapter::Abstract.data_for_field(f, value))
      end
    end

  end

  class Collection < ContainerField

    def initialize(options={}, &block)
      options[:numbered] = true if options[:numbered].nil?
      super(options, &block)
    end

  end

  class Boolean < Field
  end

end
