require 'hammer_cli/defaults_commands'
module HammerCLI
  DEFAULT_FILE = "#{Dir.home}/.hammer/defaults.yml"

  class Defaults
    class DefaultsError < StandardError; end
    class DefaultsPathError < DefaultsError; end

    attr_reader :defaults_settings

    def initialize(settings, file_path = nil)

      @defaults_settings = settings || {}
      @path = file_path || DEFAULT_FILE
    end

    def register_provider(provider)
      providers[provider.provider_name.to_s] = provider
    end

    def providers
      @providers ||= {}
    end

    def delete_default_from_conf(param)
      update_defaults_file do |defaults|
        defaults.delete_if { |k,| defaults_match?(k, param) }
      end
    end

    def add_defaults_to_conf(default_options, provider)
      create_default_file if defaults_settings.empty?
      update_defaults_file do |defaults|
        default_options.each do |key, value|
          key = switch_to_name(key).to_sym
          defaults.delete_if { |k,| defaults_match?(k, key) }
          defaults[key] = (value ? {:value => value} : {:provider => provider})
        end
      end
    end

    def defaults_set?(param)
      defaults_settings.keys.any? { |k| defaults_match?(k, param) }
    end

    def get_defaults(opt)
      unless defaults_settings.nil?
        option_key = normalize_option(opt)
        settings_key = defaults_settings[option_key.to_sym].nil? ? option_key.gsub('_','-').to_sym : option_key.to_sym

        return nil if defaults_settings[settings_key].nil?

        if defaults_settings[settings_key][:provider]
          providers[defaults_settings[settings_key][:provider]].get_defaults(option_key.to_sym)
        else
          defaults_settings[settings_key][:value]
        end
      end
    end

    def write_to_file(defaults)
      File.open(path,'w') do |h|
        h.write defaults.to_yaml
      end
    end

    protected

    attr_reader :path

    def create_default_file
      if Dir.exist?(File.dirname(@path))
        new_file = File.new(path, "w")
        new_file.write ":defaults:"
        new_file.close
      else
        raise DefaultsPathError.new(_("Couldn't create %s. Please create the directory before setting defaults.") % path)
      end
    end

    def update_defaults_file
      conf_file = YAML.load_file(@path)
      conf_file[:defaults] ||= {}
      yield conf_file[:defaults]
      write_to_file conf_file
      conf_file
    end

    private

    def defaults_match?(default_a, default_b)
      normalize_option(default_a) == normalize_option(default_b)
    end

    def normalize_option(opt)
      switch_to_name(opt).gsub(/^option_/,'').gsub('-','_')
    end

    def switch_to_name(opt)
      opt.to_s.gsub(/^-[-]?/,'')
    end
  end

  def self.defaults
    @defaults ||= Defaults.new(HammerCLI::Settings.settings[:defaults])

  end

  HammerCLI::MainCommand.subcommand "defaults", _("Defaults management"), HammerCLI::DefaultsCommand
end
