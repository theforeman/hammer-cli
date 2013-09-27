require 'yaml'
require 'logging'

module HammerCLI

  class Settings

    def self.get(*keys)
      keys.inject(settings) do |value, key|
        return nil unless value
        value[key.to_sym]
      end
    end

    def self.load_from_file(files)
      files.reverse.each do |path|
        full_path = File.expand_path path
        if File.exists? full_path
          config = YAML::load(File.open(full_path))
          if config
            load(config)
            path_history << full_path
          end
        end
      end
    end

    def self.load(settings_hash)
      deep_merge!(settings, settings_hash)
    end

    def self.clear
      settings.clear
      path_history.clear
    end

    def self.path_history
      @path_history ||= []
      @path_history
    end

    private
    def self.settings
      @settings_hash ||= {}
      @settings_hash
    end

    def self.deep_merge!(h, other_h)
      other_h = symbolize_hash(other_h)

      h.merge!(other_h) do |key, old_val, new_val|
        if old_val.is_a? Hash and new_val.is_a? Hash
          deep_merge!(old_val, new_val)
        else
          new_val
        end
      end
    end

    def self.symbolize_hash(h)
      h = h.inject({}) { |sym_hash,(k,v)| sym_hash.update(k.to_sym => v) }
    end
  end


end
