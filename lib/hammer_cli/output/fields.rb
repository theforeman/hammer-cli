require 'hammer_cli/output/dsl'

module Fields
  class Field
    attr_reader :path
    attr_writer :sets
    attr_accessor :label, :parent

    def initialize(options={})
      @hide_blank = options[:hide_blank].nil? ? false : options[:hide_blank]
      @hide_missing = options[:hide_missing].nil? ? true : options[:hide_missing]
      @path = options[:path] || []
      @label = options[:label]
      @sets = options[:sets]
      @options = options
    end

    def id
      @options[:id] || @options[:key] || @label
    end

    def match_id?(field_id)
      @options[:id] == field_id || @options[:key] == field_id || @label == _(field_id)
    end

    def hide_blank?
      @hide_blank
    end

    def hide_missing?
      @hide_missing
    end

    def full_label
      return @label.to_s if @parent.nil?
      "#{@parent.full_label}/#{@label}"
    end

    def sets
      @sets || inherited_sets || default_sets
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

    protected

    def inherited_sets
      return nil if @parent.nil?
      @parent.sets
    end

    def default_sets
      %w[DEFAULT ALL]
    end
  end


  class ContainerField < Field

    def initialize(options={}, &block)
      super(options)
      dsl = HammerCLI::Output::Dsl.new
      dsl.build &block if block_given?
      dsl.fields.each { |f| f.parent = self }
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

  class Text < Field
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
