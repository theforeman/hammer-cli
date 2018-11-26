require_relative '../option_processor'

module HammerCLI
  module Options
    module Validators
      class ValidationError < StandardError
      end

      class Base < HammerCLI::Options::OptionProcessor
        def process(defined_options, result)
          run(defined_options, result)
          result
        end

        def run(defined_options, result)
        end
      end
    end
  end
end
