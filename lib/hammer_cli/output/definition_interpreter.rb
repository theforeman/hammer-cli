require 'hammer_cli/output/adapter/base'

module HammerCLI::Output
  class DefinitionInterpreter

    def initialize(options={})
      @definition = options[:definition] or raise "Definition is required"
    end

    def run(records)
      @records = records
      @records = [@records] unless @records.kind_of?(Array)
      return [fields, data]
    end

    protected

    def fields
      @definition.fields.collect do |field|
        HammerCLI::Output::Field.new(field.key, field.label, field.options)
      end
    end

    def data
      @records.collect do |record|
        @definition.fields.inject({}) do |result, field|
          result.update field.key => value_for_field(field, record)
        end
      end
    end

    def symbolize_hash_keys(h)
      return h.inject({}){|result,(k,v)| result.update k.to_sym => v}
    end

    def value_for_field(field, record)
      record = follow_path(record, field.path || [])

      if field.record_formatter
        return field.record_formatter.call(record)
      else
        value = record[field.key.to_sym] rescue nil
        return field.formatter.call(value) if field.formatter
        return value
      end
    end

    def follow_path(record, path)
      record = symbolize_hash_keys(record)
      path.inject(record) do |record, path_key|
        if record.has_key? path_key.to_sym
          symbolize_hash_keys record[path_key.to_sym]
        else
          return nil
        end
      end
    end

  end
end
