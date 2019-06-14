# frozen_string_literal: true

module HammerCLI
  module Options
    # Contains predefined by HammerCLI options for commands
    module Predefined
      OPTIONS = {
        fields: [['--fields'], 'FIELDS',
                 _('Show specified fileds or predefined filed sets only. (See below)'),
                 format: HammerCLI::Options::Normalizers::List.new,
                 context_target: :fields]
      }.freeze

      def self.use(option_name, command_class)
        unless OPTIONS.key?(option_name)
          raise ArgumentError, _('There is no such predefined option %s.') % option_name
        end
        command_class.send(:option, *OPTIONS[option_name])
      end
    end
  end
end
