module HammerCLI::Apipie

  class ResourceDefinition

    attr_reader :resource_class

    def initialize(resource_class)
      @resource_class = resource_class
    end

    def name
      resource_class.name.split("::")[-1].downcase
    end

    def plural_name
      irregular_names = {
        "statistics" => "statistics",
        "home" => "home",
        "host_class" => "host_classes",
        "medium" => "media",
        "puppetclass" => "puppetclasses",
        "dashboard" => "dashboard",
        "smart_proxy" => "smart_proxies",
        "settings" => "settings",
        "hostgroup_class" => "hostgroup_classes"
      }
      irregular_names[name] || "%ss" % name
    end

    def docs_for(method_name)
      resource_class.doc["methods"].each do |method|
        return method if method["name"] == method_name.to_s
      end
      raise "No method documentation found for #{resource_class}##{method_name}"
    end

  end


  class ResourceInstance < ResourceDefinition

    def initialize(resource_class, config)
      super(resource_class)
      @instance = resource_class.new(config)
    end

    def self.from_definition(definition, config)
      self.new(definition.resource_class, config)
    end

    def call(method_name, params=nil, headers=nil)
      Logging.logger[resource_class.name].debug "Calling '#{method_name}' with params #{params.ai}" if HammerCLI::Settings.get(:log_api_calls)
      result = @instance.send(method_name, params, headers)
      Logging.logger[resource_class.name].debug "Method '#{method_name}' responded with #{result[0].ai}" if HammerCLI::Settings.get(:log_api_calls)
      result
    end

    private

    attr_reader :instance

  end


  class ApipieConnector < HammerCLI::Apipie::ResourceInstance

    def initialize(params)
      definition = params.delete(:definition)
      if definition
        super(definition.resource_class, params)
      else
        raise ArgumentError.new('ApipieConnector: Resource definition not set')
      end
    end

  end


  module Resource

    def self.included(base)
      base.extend(ClassMethods)
    end

    def resource
      # if the resource definition is not available in this command's class
      # or its superclass try to look it up in parent command's class
      if self.class.resource
        resource_def = self.class.resource
      else
        resource_def = self.parent_command.class.resource
      end
      HammerCLI::Connection.get(connection_name(resource_def.resource_class), resource_config.merge(:definition => resource_def), connection_options)
    end

    def connection_name(resource_class)
      if resource_class.respond_to? :name
        resource_class.name.split('::').last
      else
        resource_class.to_s
      end
    end

    def action
      self.class.action
    end

    def resource_config
      self.class.resource_config
    end

    def connection_options
      self.class.connection_options
    end

    module ClassMethods

      def resource_config
        {}
      end

      def connection_options
        {
          :connector => HammerCLI::Apipie::ApipieConnector
        }
      end

      def class_resource
        return @api_resource if @api_resource
        return superclass.class_resource if superclass.respond_to? :class_resource
      end

      def module_resource
        return nil unless self.name
        enclosing_module = self.name.split("::")[0..-2].inject(Object) { |mod, cls| mod.const_get cls }

        if enclosing_module.respond_to? :resource
          enclosing_module.resource
        end
      end

      def resource(resource_class=nil, action=nil)
        @api_resource = ResourceDefinition.new(resource_class) unless resource_class.nil?
        @api_action = action unless action.nil?

        # if the resource definition is not available in this class
        # try to look it up in it's enclosing module/class
        return class_resource || module_resource
      end

      def action(action=nil)
        @api_action = action unless action.nil?
        return @api_action if @api_action
        return superclass.action if superclass.respond_to? :action
      end

      def resource_defined?
        not (resource.nil? or action.nil?)
      end

    end

  end
end
