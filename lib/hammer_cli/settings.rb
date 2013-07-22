module HammerCLI

  class Settings

    def self.load_from_file files
      s = self.new
      s.load_from_file files
      s
    end

    def [] key
      settings[key.to_sym]
    end

    def load_from_file files
      files.reverse.each do |path|
        if File.exists? path
          config = YAML::load(File.open(path))
          load(config)
        end
      end
    end

    def load settings_hash
      settings.merge! settings_hash.inject({}){ |sym_hash,(k,v)| sym_hash[k.to_sym] = v; sym_hash }
    end

    def clear
      settings.clear
    end

    private
    def settings
      @settings_hash ||= {}
      @settings_hash
    end

  end


end
