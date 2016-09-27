require 'hammer_cli/output/utils'

module TablePrint
  class FixedWidthFormatter
    def format(value)
      value = value.to_s
      padding = width - HammerCLI::Output::Utils.real_length(value)
      if padding >= 0
        value += (" " * padding)
      else
        value, real_length = HammerCLI::Output::Utils.real_truncate(value, width-3)
        value += '...'
        value += ' ' if real_length < (width - 3)
      end
      value
    end
  end
end
