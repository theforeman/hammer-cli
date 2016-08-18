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

    def self.load_from_paths(files)
      files.reverse.each do |path|
        full_path = File.expand_path path
        if File.directory? full_path
          # check for cli_config.yml
          load_from_file(File.join(full_path, 'cli_config.yml'))
          load_from_file(File.join(full_path, 'defaults.yml'))
          # load config for modules
          Dir.glob(File.join(full_path, 'cli.modules.d/*.yml')).sort.each do |f|
            load_from_file(f)
          end
          Dir.glob(File.join(full_path, 'hammer.modules.d/*.yml')).sort.each do |f|
            warn _("Warning: location hammer.modules.d is deprecated, move your module configurations to cli.modules.d")
            warn "    #{f} -> #{f.gsub('hammer.modules.d', 'cli.modules.d')}"
            load_from_file(f)
          end
        end
      end
    end

    def self.load_from_file(file_path)
      if File.file? file_path
        begin
          config = YAML::load(File.open(file_path))
          if config
            load(config)
            path_history << file_path
          end
        rescue Exception => e
          warn _("Warning: Couldn't load configuration file %{path}: %{message}") % { path: file_path, message: e.message }
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

    def self.dump
      settings
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
        elsif old_val.is_a? Array and new_val.is_a? Array
          old_val += new_val
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
