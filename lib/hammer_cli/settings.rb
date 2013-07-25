require 'yaml'

module HammerCLI

  class Settings

    def self.[] key
      settings[key.to_sym]
    end

    def self.load_from_file files
      files.reverse.each do |path|
        full_path = File.expand_path path
        if File.exists? full_path
          config = YAML::load(File.open(full_path))
          load(config) if config
        end
      end
    end

    def self.load settings_hash
      settings.merge! settings_hash.inject({}){ |sym_hash,(k,v)| sym_hash[k.to_sym] = v; sym_hash }
    end

    def self.clear
      settings.clear
    end

    private
    def self.settings
      @settings_hash ||= {}
      @settings_hash
    end

  end


end
