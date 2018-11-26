require_relative '../option_processor'

module HammerCLI
  module Options
    module Sources
      class Base < HammerCLI::Options::OptionProcessor
        def process(defined_options, result)
          get_options(defined_options, result)
        end

        def get_options(defined_options, result)
          result
        end
      end
    end
  end
end
