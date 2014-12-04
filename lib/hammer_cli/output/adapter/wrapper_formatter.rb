module HammerCLI::Output::Adapter

  class WrapperFormatter

    def initialize(formatter, params)
      @formatter = formatter
      @params = params
    end

    def format(value)
      if @formatter
        @formatter.format(value, @params)
      else
        value
      end
    end

  end

end
