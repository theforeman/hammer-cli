module HammerCLI
  module Options
    class OptionCollector
      attr_accessor :option_sources

      def initialize(recognised_options, option_sources)
        @recognised_options = recognised_options
        @option_sources = option_sources
      end

      def all_options_raw
        @all_options_raw ||= @option_sources.inject({}) do |all_options, source|
          source.get_options(@recognised_options, all_options)
        end
      end

      def all_options
        @all_options ||= translate_nils(all_options_raw)
      end

      def options
        @options ||= all_options.reject {|key, value| value.nil? && all_options_raw[key].nil? }
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
