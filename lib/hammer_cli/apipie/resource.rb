module HammerCLI::Apipie
  module Resource

    def self.included(base)
      base.extend(ClassMethods)
    end

    def resource
      self.class.resource.new resource_config
    end

    def action
      self.class.action
    end

    def resource_config
      config = {}
      if context[:settings]
        config[:base_url] = context[:settings][:host]
        config[:username] = context[:settings][:username]
        config[:password] = context[:settings][:password]
      end
      config
    end

    module ClassMethods


      def resource resource=nil, action=nil
        @api_resource = resource unless resource.nil?
        @api_action = action unless action.nil?
        return @api_resource if @api_resource
        return superclass.resource
      end

      def action action=nil
        @api_action = action unless action.nil?
        @api_action
      end

      def method_doc
        @api_resource.doc["methods"].each do |method|
          return method if method["name"] == @api_action.to_s
        end
        raise "No method documentation found for #{@api_resource}##{@api_action}"
      end

      def resource_defined?
        not (@api_resource.nil? or @api_action.nil?)
      end

    end

  end
end
