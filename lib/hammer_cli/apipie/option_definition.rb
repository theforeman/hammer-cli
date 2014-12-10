require File.join(File.dirname(__FILE__), 'options')

module HammerCLI::Apipie

  class OptionDefinition < HammerCLI::Options::OptionDefinition

    attr_accessor :referenced_resource

    def initialize(switches, type, description, options = {})
      if options.has_key? :referenced_resource
        self.referenced_resource = options.delete(:referenced_resource).to_s if options[:referenced_resource]
      end
      super
    end

  end

end
