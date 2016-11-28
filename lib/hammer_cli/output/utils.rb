require 'unicode/display_width'

module HammerCLI
  module Output
    module Utils
      def self.real_length(value)
        decolorized = value.gsub(/\033\[[^m]*m/, '')
        Unicode::DisplayWidth.of(decolorized)
      end

      def self.real_char_length(ch)
        Unicode::DisplayWidth.of(ch)
      end

      def self.real_truncate(value, required_size)
        size = 0
        index = 0
        has_colors = false
        in_color = false
        value.each_char do |ch|
          if in_color
            in_color = false if ch == "m"
          elsif ch == "\e"
            has_colors = in_color = true
          else
            increment = real_char_length(ch)
            if size + increment > required_size
              if has_colors
                return value[0..index-1] + "\e[0m", size
              else
                return value[0..index-1], size
              end
            else
              size += increment
            end
          end
          index += 1
        end
        return value, size
      end
    end
  end
end
