require 'hammer_cli/output/dsl'

module Fields

  class Field

    attr_reader :label
    attr_reader :path

    def initialize(options={})
      @hide_blank = options[:hide_blank].nil? ? false : options[:hide_blank]
      @path = options[:path] || []
      @label = options[:label]
      @options = options
    end

    def hide_blank?
      @hide_blank
    end

    def display?(value)
      if not hide_blank?
        true
      elsif value.nil?
        false
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
      if not hide_blank?
        true
      elsif value.nil? || value.empty?
        false
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
  end

  class Collection < ContainerField
  end

  class Boolean < Field
  end

end
