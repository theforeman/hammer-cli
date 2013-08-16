module HammerCLI
  module OptionFormatters

    def self.list(val)
      val.is_a?(String) ? val.split(",") : []
    end

  end
end
