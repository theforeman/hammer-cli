module HammerCLI
  module Options
    class OptionCollector
      attr_accessor :option_processor

      def initialize(recognised_options, option_processor)
        @recognised_options = recognised_options

        if !option_processor.is_a?(HammerCLI::Options::ProcessorList)
          @option_processor = HammerCLI::Options::ProcessorList.new(option_processor)
        else
          @option_processor = option_processor
        end
      end

      def all_options_raw
        @all_options_raw ||= @option_processor.process(@recognised_options, {})
      end

      def all_options
        @all_options ||= translate_nils(all_options_raw)
      end

      def options
        @options ||= all_options.reject { |key, value| value.nil? && all_options_raw[key].nil? }
      end

      private

      def translate_nils(opts)
        Hash[ opts.map { |k,v| [k, translate_nil(v)] } ]
      end

      def translate_nil(value)
        value == HammerCLI::NilValue ? nil : value
      end
    end
  end
end
