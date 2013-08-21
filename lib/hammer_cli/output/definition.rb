module HammerCLI::Output

  class Definition

    attr_accessor :fields

    def initialize
      @fields = []
    end

    def append(fields)
      @fields += fields
    end

  end

end
