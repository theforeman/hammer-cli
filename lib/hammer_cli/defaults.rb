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
      conf_file = YAML.load_file(path)
      conf_file[:defaults].delete_if { |k,| k.to_s.gsub('-','_') == param.to_s.gsub('-','_') }
      write_to_file conf_file
      conf_file
    end

    def add_defaults_to_conf(default_options, provider)
      create_default_file if defaults_settings.empty?
      defaults = YAML.load_file(path)
      defaults[:defaults] ||= {}
      default_options.each do |key, value|
        key = key.to_sym
        defaults[:defaults].delete_if { |k,| k.to_s.gsub('-','_') == key.to_s.gsub('-','_') }
        defaults[:defaults][key] = (value ? {:value => value,} : {:provider => provider})
      end
      write_to_file defaults
      defaults
    end

    def defaults_set?(param)
      defaults_settings.keys.any? { |k| k.to_s.gsub('-','_') == param.to_s.gsub('-','_') }
    end

    def get_defaults(opt)
      option = opt
      option = opt.gsub("option_",'') if opt.include? "option_"
      unless defaults_settings.nil?
        option_key = defaults_settings[option.to_sym].nil? ? option.gsub('_','-').to_sym : option.to_sym
        return nil if defaults_settings[option_key].nil?

        if defaults_settings[option_key][:provider]
          providers[defaults_settings[option_key][:provider]].get_defaults(option.to_sym)
        else
          defaults_settings[option_key][:value]
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
        raise DefaultsPathError.new(_("Couldn't create %s please create the path before defaults are enabled.") % path)
      end
    end
  end

  def self.defaults
    @defaults ||= Defaults.new(HammerCLI::Settings.settings[:defaults])

  end

  HammerCLI::MainCommand.subcommand "defaults", _("Defaults management"), HammerCLI::DefaultsCommand
end
