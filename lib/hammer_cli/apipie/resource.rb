module HammerCLI::Apipie

  class ResourceDefinition

    attr_reader :resource_class

    def initialize(resource_class)
      @resource_class = resource_class
    end

    def name
      resource_class.name.split("::")[-1].downcase
    end

    def docs_for(method_name)
      resource_class.doc["methods"].each do |method|
        return method if method["name"] == method_name.to_s
      end
      raise "No method documentation found for #{resource_class}##{action}"
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

    def call(method_name, params=nil)
      instance.send(method_name, params)
    end

    private

    attr_reader :instance

  end


  module Resource

    def self.included(base)
      base.extend(ClassMethods)
    end

    def resource
      # if the resource definition is not available in this command's class
      # try to look it up in parent command's class
      if self.class.resource
        return ResourceInstance.from_definition(self.class.resource, resource_config)
      else
        return ResourceInstance.from_definition(self.parent_command.class.resource, resource_config)
      end
    end

    def action
      self.class.action
    end

    def resource_config
      config = {}
      config[:base_url] = HammerCLI::Settings[:host]
      config[:username] = context[:username] || HammerCLI::Settings[:username] || ENV['FOREMAN_USERNAME']
      config[:password] = context[:password] || HammerCLI::Settings[:password] || ENV['FOREMAN_PASSWORD']
      config
    end

    module ClassMethods

      def resource resource_class=nil, action=nil
        @api_resource = ResourceDefinition.new(resource_class) unless resource_class.nil?
        @api_action = action unless action.nil?
        return @api_resource if @api_resource

        # if the resource definition is not available in this class
        # try to look it up in it's enclosing module/class
        enclosing_module = self.name.split("::")[0..-2].inject(Object) { |mod, cls| mod.const_get cls }

        if enclosing_module.respond_to? :resource
          enclosing_module.resource
        end
      end

      def action action=nil
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
