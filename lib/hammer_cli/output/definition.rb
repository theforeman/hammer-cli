module HammerCLI::Output

  class Field

    def initialize(key, label, options={})
      @key = key
      @label = label
      @options = options
    end

    attr_reader :key, :label, :options
  end


  class Definition

    class Field < HammerCLI::Output::Field

      def initialize(key, label, options={})
        @formatter = options.delete(:formatter)
        @formatter = Proc.new if block_given?
        @record_formatter = options.delete(:record_formatter)
        @path = options.delete(:path) || []
        @path = [@path] unless @path.kind_of? Array
        super key, label, options
      end

      attr_reader :formatter, :record_formatter, :path
    end

    def initialize
      @fields = []
    end

    def add_field(key, label, options={}, &block)
      @fields << Field.new(key, label, options, &block)
    end

    def append(definition)
      @fields += definition.fields unless definition.nil?
    end

    def fields
      @fields
    end

  end

end
