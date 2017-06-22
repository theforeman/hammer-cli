module HammerCLI
  class CSVParser

    def initialize
      reset_parser
    end

    def parse(data)
      return [] if data.nil?
      reset_parser
      data.split('').each do |char|
        handle_escape(char) || handle_quoting(char) || handle_comma(char) || add_to_buffer(char)
      end
      raise ArgumentError.new(_("Illegal quoting in %{buffer}") % { :buffer => @buffer }) unless @last_quote.nil?
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
        true
      elsif @last_quote == char
        @last_quote = nil
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
        true
      else
        false
      end
    end

    def add_to_buffer(char)
      @buffer += char
    end

    def reset_parser
      @value = []
      @buffer = ''
      @escape = false
      @last_quote = nil
    end

    def clean_buffer
      @value << @buffer
      @buffer = ''
    end
  end
end
