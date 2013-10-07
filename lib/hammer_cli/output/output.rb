module HammerCLI::Output
  class Output

    def self.print_message(msg, context, options={})
      adapter(options[:adapter], context).print_message(msg.to_s)
    end

    def self.print_error(msg, details=nil, context={}, options={})
      adapter(options[:adapter], context).print_error(msg.to_s, details)
    end

    def self.print_records(definition, records, context, options={})
      adapter(options[:adapter], context).print_records(definition.fields, [records].flatten(1))
    end

    def self.adapter(req_adapter, context)
      if context[:adapter]
        adapter_name = context[:adapter].to_sym
      else
        adapter_name = req_adapter
      end

      begin
        init_adapter(adapter_name, context)
      rescue NameError
        Logging.logger[self.name].warn("Required adapter '#{adapter_name}' was not found, using 'base' instead")
        init_adapter(:base, context)
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
    
    def self.init_adapter(adapter_name, context)
      raise NameError unless adapters.has_key? adapter_name
      adapters[adapter_name].new(context, formatters)
    end

  end
end
