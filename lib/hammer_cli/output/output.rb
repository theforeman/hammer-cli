module HammerCLI::Output
  class Output

    def initialize options={}
      @adapter = options[:adapter] || HammerCLI::Output::Adapter::Base.new
      @definition = options[:definition] || HammerCLI::Output::Definition.new
      @interpreter = options[:interpreter] || HammerCLI::Output::DefinitionInterpreter.new(:definition => @definition)
    end

    attr_accessor :adapter
    attr_reader :definition, :interpreter

    def print_message msg
      adapter.print_message(msg.to_s)
    end

    def print_error msg, details=nil
      adapter.print_error(msg.to_s, details)
    end

    def print_records records, heading=nil
      records = [records] unless records.kind_of?(Array)

      fields, data = interpreter.run(records)
      adapter.print_records(fields, data, heading)
    end

  end
end
