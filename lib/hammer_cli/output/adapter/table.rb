require 'terminal-table'

module HammerCLI::Output::Adapter
  class Table < Abstract

    def print_records(fields, data, heading=nil)
      headings = fields.collect{|f| f.label.to_s}
      rows = data.collect do |d|
        fields.collect do |f|
          f.get_value(d).to_s
        end
      end

      table = Terminal::Table.new(:headings => headings,
                                  :rows => rows,
                                  :style => {
                                    :border_y => '',
                                    :border_i => '',
                                    :border_x => '-'
                                  })
      puts table
    end

  end
end
