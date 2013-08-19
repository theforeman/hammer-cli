require 'hammer_cli/output/dsl'

module HammerCLI::Apipie

  class ReadCommand < Command

      extend HammerCLI::Output::Dsl

      def output_definition
        self.class.output_definition
      end

      def output
        @output ||= HammerCLI::Output::Output.new :definition => output_definition
      end

      def execute
        d = retrieve_data
        logger.watch "Retrieved data: ", d
        print_data d
        return 0
      end

      protected
      def retrieve_data
        raise "resource or action not defined" unless self.class.resource_defined?
        resource.send(action, request_params)[0]
      end

      def print_data(records)
        output.print_records(records, self.class.output_heading)
      end

      def request_params
        method_options
      end

  end

end


