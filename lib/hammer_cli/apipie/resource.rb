module HammerCLI::Apipie
  module Resource

    def self.included(base)
      base.extend(ClassMethods)
    end

    def resource
      @resource ||= self.class.resource.new resource_config
      @resource
    end

    def resource_name
      self.class.resource.name.split("::")[-1].downcase
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


      def resource resource=nil, action=nil
        @api_resource = resource unless resource.nil?
        @api_action = action unless action.nil?
        return @api_resource if @api_resource

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

      def method_doc
        resource.doc["methods"].each do |method|
          return method if method["name"] == action.to_s
        end
        raise "No method documentation found for #{resource}##{action}"
      end

      def resource_defined?
        not (resource.nil? or action.nil?)
      end

    end

  end
end
