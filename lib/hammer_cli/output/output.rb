module HammerCLI::Output
  class Output

    attr_accessor :adapter
    attr_reader :definition

    def initialize(options={})
      @adapter = options[:adapter] || HammerCLI::Output::Adapter::Base.new
      @definition = options[:definition] || HammerCLI::Output::Definition.new
    end

    def print_message(msg)
      adapter.print_message(msg.to_s)
    end

    def print_error(msg, details=nil)
      adapter.print_error(msg.to_s, details)
    end

    def print_records(records, heading=nil)
      records = [records] unless records.kind_of?(Array)

      adapter.print_records(definition.fields, records, heading)
    end

  end
end
