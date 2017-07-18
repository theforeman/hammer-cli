module HammerCLI
  class CSVParser

    def initialize
      reset_parser
    end

    def parse(data)
      return [] if data.nil?
      reset_parser
      data.each_char do |char|
        handle_escape(char) || handle_quoting(char) || handle_comma(char) || add_to_buffer(char)
      end
      raise ArgumentError.new(_("Illegal quoting in %{buffer}") % { :buffer => @raw_buffer }) unless @last_quote.nil?
      clean_buffer
      @value
    end

    private

    def handle_comma(char)
      if char == ','
        clean_buffer
        true
      else
        false
      end
    end

    def handle_quoting(char)
      if @last_quote.nil? && ["'", '"'].include?(char)
        @last_quote = char
        @raw_buffer += char
        true
      elsif @last_quote == char
        @last_quote = nil
        @raw_buffer += char
        true
      elsif @last_quote
        add_to_buffer(char)
        true
      else
        false
      end
    end

    def handle_escape(char)
      if @escape
        add_to_buffer(char)
        @escape = false
        true
      elsif char == '\\'
        @escape = true
        @raw_buffer += char
        true
      else
        false
      end
    end

    def add_to_buffer(char)
      @buffer += char
      @raw_buffer += char
    end

    def reset_parser
      @value = []
      @buffer = ''
      @raw_buffer = ''
      @escape = false
      @last_quote = nil
    end

    def clean_buffer
      @value << @buffer
      @raw_buffer = ''
      @buffer = ''
    end
  end
end
