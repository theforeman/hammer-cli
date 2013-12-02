require 'hammer_cli/output/dsl'

module HammerCLI::Apipie

  class ReadCommand < Command

      def execute
        d = retrieve_data
        logger.debug "Retrieved data: " + d.ai(:raw => true) if HammerCLI::Settings.get(:log_api_calls)
        print_data d
        return HammerCLI::EX_OK
      end

      protected
      def retrieve_data
        raise "resource or action not defined" unless self.class.resource_defined?
        resource.call(action, request_params)[0]
      end

      def print_data(records)
        print_collection(output_definition, records)
      end

      def request_params
        method_options
      end

  end

end


