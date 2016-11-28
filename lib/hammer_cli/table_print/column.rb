require 'hammer_cli/output/utils'

module TablePrint
  class Column
    def data_width
      if multibyte_count
        [
          HammerCLI::Output::Utils.real_length(name),
          Array(data).compact.collect(&:to_s).collect{|m| HammerCLI::Output::Utils.real_length(m) }.max
        ].compact.max || 0
      else
        [
          name.length,
          Array(data).compact.collect(&:to_s).collect(&:length).max
        ].compact.max || 0
      end
    end
  end
end
