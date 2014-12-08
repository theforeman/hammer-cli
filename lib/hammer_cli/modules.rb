require 'tsort'
module HammerCLI

  class ModulesList < Hash
    include TSort

    def tsort_each_node(&block)
      each_key.sort.each(&block)
    end

    def tsort_each_child(node, &block)
      fetch(node).each(&block)
    end
  end

  class Modules

    def self.names
      # add dependencies
      modules = find_dependencies({}, enabled_modules)
      # sort with the deps in mind
      ModulesList[modules].tsort
    rescue TSort::Cyclic => e
      raise HammerCLI::ModuleCircularDependency.new(_("Unable to load modules: Circular dependency detected (%s)") % e.message)
    end


    def self.find_dependencies(dependencies, module_list)
      new_deps = []

      # add inspected modules in current level (depth)
      dependencies.merge(Hash[module_list.map{ |m| [m, []] }])

      # lookup dependencies
      module_list.each do |mod|
        deps = dependencies_for(mod)
        logger.debug(_("Module depenedency detected: %{mod} requires %{deps}") % { :mod => mod, :deps => deps.join(', ') }) unless deps.empty?
        dependencies[mod] = deps # update deps
        # check new/disabled deps
        deps.each do |dep|
          if !dependencies.has_key?(dep)
            if HammerCLI::Settings.get(dep.gsub(/^hammer_cli_/, ''), :enable_module) == false
              raise HammerCLI::ModuleDisabledButRequired.new(_("Module %{mod} depends on module %{dep} which is disabled in configuration") % { :mod => mod, :dep => dep })
            end
            new_deps << dep
          end
        end
      end
      dependencies = find_dependencies(dependencies, new_deps) unless new_deps.empty?
      dependencies
    end

    def self.dependencies_for(module_name)
      mod = if Gem::Specification.respond_to? :find_by_name
              Gem::Specification.find_by_name(module_name)
            else
              Gem.source_index.search(Gem::Dependency.new(module_name, Gem::Requirement.default)).first
            end
      mod.dependencies.select{ |dep| dep.name =~ /^hammer_cli_.*/ }.map(&:name)
    end

    def self.enabled_modules
      # legacy modules config
      modules = HammerCLI::Settings.get(:modules) || []
      logger.warn _("Legacy configuration of modules detected. Check section about configuration in user manual") unless modules.empty?

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
        logger.error "Error while loading module #{name}"
        puts _("Warning: An error occured while loading module %s") % name
        # with ModuleLoadingError we assume the error is already logged by the issuer
        logger.error e unless e.is_a?(HammerCLI::ModuleLoadingError)
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

    def self.is_module_config?(config)
      config.kind_of?(Hash) && !config[:enable_module].nil?
    end

    def self.logger
      Logging.logger['Modules']
    end

  end

end
