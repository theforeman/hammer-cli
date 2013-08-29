require 'hammer_cli/output/dsl'

module HammerCLI::Apipie

  class ReadCommand < Command

      def self.output definition=nil, &block
        dsl = HammerCLI::Output::Dsl.new
        dsl.build &block

        output_definition.append definition.fields unless definition.nil?
        output_definition.append dsl.fields
      end

      def self.heading heading=nil
        @heading = heading if heading
        @heading
      end

      def output_definition
        self.class.output_definition
      end

      def self.output_definition
        @output_definition ||= HammerCLI::Output::Definition.new
        @output_definition
      end

      def output
        @output ||= HammerCLI::Output::Output.new :definition => output_definition
      end

      def execute
        d = retrieve_data
        logger.watch "Retrieved data: ", d
        print_data d
        return HammerCLI::EX_OK
      end

      protected
      def retrieve_data
        raise "resource or action not defined" unless self.class.resource_defined?
        resource.send(action, request_params)[0]
      end

      def print_data(records)
        output.print_records(records, self.class.heading)
      end

      def request_params
        method_options
      end

  end

end


