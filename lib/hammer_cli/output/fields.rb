require 'hammer_cli/output/dsl'

module Fields

  class Field

    attr_reader :label
    attr_reader :path

    def initialize(options={})
      @path = options[:path] || []
      @label = options[:label]
    end

    def get_value(data)
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

  end

  class Date < Field
  end

  class Id < Field
  end

  class List < Field
  end

  class KeyValue < Field
  end

  class Label < ContainerField
  end

  class Collection < ContainerField
  end

end
