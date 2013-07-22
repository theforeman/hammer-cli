require 'terminal-table'

module HammerCLI::Output::Adapter
  class Base < Abstract

    def print_records fields, data, heading=nil

      spacer = [nil, nil, nil]

      rows = [spacer]
      data.each do |d|
        fields.collect do |f|
          key = f.label.to_s
          value = d[f.key].to_s
          rows << [key, ":", value]
        end
        rows << spacer
      end

      table = Terminal::Table.new :title => heading,
                                  :rows => rows,
                                  :style => { :border_y => '', :border_i => '', :border_x => '-'}
      puts table
    end

  end
end
