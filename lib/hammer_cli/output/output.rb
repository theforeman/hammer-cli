module HammerCLI::Output
  class Output

    def initialize(context={}, options={})
      self.context = context
      self.default_adapter = options[:default_adapter]
    end

    attr_accessor :default_adapter

    def print_message(msg, msg_params={})
      adapter.print_message(msg.to_s, msg_params)
    end

    def print_error(msg, details=nil, msg_params={})
      adapter.print_error(msg.to_s, details, msg_params)
    end

    def print_record(definition, record)
      adapter.print_record(definition.fields, record)
    end

    def print_collection(definition, collection)
      unless collection.class <= HammerCLI::Output::RecordCollection
        collection = HammerCLI::Output::RecordCollection.new([collection].flatten(1))
      end
      adapter.print_collection(definition.fields, collection)
    end

    def adapter
      adapter_name = context[:adapter] || default_adapter

      begin
        init_adapter(adapter_name.to_sym)
      rescue NameError
        Logging.logger[self.class.name].warn("Required adapter '#{adapter_name}' was not found, using 'base' instead")
        init_adapter(:base)
      end
    end

    def self.adapters
      @adapters_hash ||= {}
      @adapters_hash
    end

    def self.formatters
      @formatters_hash ||= {}
      @formatters_hash
    end

    def self.register_adapter(name, adapter_class)
      adapters[name] = adapter_class
    end

    def self.register_formatter(formatter, *field_types)
      field_types.each do |type|
        formatter_list = formatters[type] || []
        formatter_list << formatter
        formatters[type] = formatter_list
      end
    end

    private

    attr_accessor :context

    def init_adapter(adapter_name)
      raise NameError unless self.class.adapters.has_key? adapter_name
      self.class.adapters[adapter_name].new(context, self.class.formatters)
    end

  end
end
