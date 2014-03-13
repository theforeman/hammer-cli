
module HammerCLI

  class Modules

    def self.names

      # legacy modules config
      modules = HammerCLI::Settings.get(:modules) || []
      logger.warn _("Legacy configuration of modules detected. Check section about configuration in user manual") unless modules.empty?

      HammerCLI::Settings.dump.inject(modules) do |names, (mod_name, mod_config)|
        if mod_config.kind_of?(Hash) && !mod_config[:enable_module].nil?
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
      rescue LoadError => e
        logger.error "Module #{name} not found"
        raise e
      rescue Exception => e
        logger.error "Error while loading module #{name}"
        logger.error e
        puts _("Warning: An error occured while loading module %s") % name
        raise e
      end

      version = find_by_name(name).version
      logger.info "Extension module #{name} (#{version}) loaded"
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
    end

    protected
    def self.logger
      Logging.logger['Modules']
    end

  end

end
