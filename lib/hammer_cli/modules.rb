module HammerCLI

  class Modules

    def self.names
      enabled_modules.sort
    end

    def self.enabled_modules
      modules = []
      HammerCLI::Settings.dump.inject(modules) do |names, (mod_name, mod_config)|
        if is_module_config?(mod_config)
          mod = ["hammer_cli_#{mod_name}"]
          if mod_config[:enable_module]
            names += mod
          else
            names -= mod # disable when enabled in legacy config
          end
        end
        names
      end
    end

    def self.disabled_modules
      HammerCLI::Settings.dump.inject([]) do |names, (mod_name, mod_config)|
        if is_module_config?(mod_config)
          mod = "hammer_cli_#{mod_name}"
          names << mod unless mod_config[:enable_module]
        end
        names
      end
    end

    def self.loaded_modules
      Object.constants. \
        select{ |c| c.to_s =~ /\AHammerCLI[A-Z]./ && Object.const_get(c).class == Module }. \
        map{ |m| m.to_s.underscore }
    end

    def self.find_by_name(name)
      possible_names = [
        name.camelize,
        name.camelize.gsub("Cli", "CLI")
      ]

      possible_names.each do |n|
        return Object.const_get(n) if Object.const_defined?(n)
      end
      return nil
    end

    def self.load!(name)
      begin
        require_module(name)
      rescue Exception => e
        logger.error "Error while loading module #{name}."
        puts _("Warning: An error occured while loading module %s.") % name
        # with ModuleLoadingError we assume the error is already logged by the issuer
        logger.error e unless e.is_a?(HammerCLI::ModuleLoadingError)
        raise e
      end

      version = find_by_name(name).version
      logger.info "Extension module #{name} (#{version}) loaded."
      true
    end

    def self.load(name)
      load! name
    rescue Exception => e
      false
    end

    def self.require_module(name)
      require name
    end

    def self.load_all
      HammerCLI::Modules.names.each do |m|
        Modules.load(m)
      end
      loaded_for_deps = loaded_modules & disabled_modules
      unless loaded_for_deps.empty?
        message = _("Error: Some of the required modules are disabled in configuration: %s.") % loaded_for_deps.join(', ')
        raise HammerCLI::ModuleDisabledButRequired.new(message)
      end
    end

    protected

    def self.is_module_config?(config)
      config.kind_of?(Hash) && !config[:enable_module].nil?
    end

    def self.logger
      Logging.logger['Modules']
    end

  end

end
