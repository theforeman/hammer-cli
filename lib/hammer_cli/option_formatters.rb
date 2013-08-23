module HammerCLI
  module OptionFormatters

    def self.list(val)
      val.is_a?(String) ? val.split(",") : []
    end

    def self.file(path)
      File.read(File.expand_path(path))
    end

  end
end
