module HammerCLI
  module Options
    class OptionCollector
      attr_accessor :option_sources

      def initialize(recognised_options, option_sources)
        @recognised_options = recognised_options
        @option_sources = option_sources
      end

      def all_options
        @all_options ||= @option_sources.inject({}) do |all_options, source|
          source.get_options(@recognised_options, all_options)
        end
      end

      def options
        @options ||= all_options.reject {|key, value| value.nil? }
      end
    end
  end
end
