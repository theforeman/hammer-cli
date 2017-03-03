require File.join(File.dirname(__FILE__), '../abstract')
require File.join(File.dirname(__FILE__), '../messages')
require File.join(File.dirname(__FILE__), 'options')
require File.join(File.dirname(__FILE__), 'resource')

module HammerCLI::Apipie

  module MultiStep

    class MutipleMasterError < StandardError; end

    class Step
      include HammerCLI::Apipie::Resource
      include HammerCLI::Apipie::Options

      module ClassMethods
        class << self
          def master
            @@master = true
          end

          def master?
            false || @@master
          end

          def priority(pr)
            @@priority = pr
          end

          alias_method :priority=, :priority
        end
      end

      attr_accessor :data

      def execute
        @data = send_request
        HammerCLI::EX_OK
      end

      def master?
        self.master?
      end

      def priority
        self.priority
      end

      protected

      # copied from command.rb
      def send_request
        if resource && resource.has_action?(action)
          resource.call(action, request_params, request_headers, request_options)
        else
          raise HammerCLI::OperationNotSupportedError, "The server does not support such operation."
        end
      end

      def request_headers
        {}
      end

      def request_options
        {}
      end
    end # class Step

    class MultiStepCommand < HammerCLI::AbstractCommand
      include HammerCLI::Messages

      class << self
        def create_option_builder
          builder = super

          # TODO: snag the options only from the master step
          builder
        end

        # copied from command.rb
        def apipie_options(*args)
          build_options(*args)
        end

        def steps
          @@steps || []
        end

        def step(cls)
          # magic to insert a step into the correct place based on its step_number
          @@steps ||= []
          @@steps << cls
          @@steps.sort_by!(&:priority)
        end

        def autoload_steps
          steps = constants.map { |c| const_get(c) }.select { |c| c <= HammerCLI::Apipie::MultiStep::Step }
          steps.each do |s|
            step(s)
          end
        end
      end # class << self

      def steps
        self.steps.map(&:new)
      end
    end # class MultiStepCommand
  end # module MultiStep
end # module HammerCLI
