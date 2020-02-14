require File.join(File.dirname(__FILE__), 'options')

module HammerCLI::Apipie

  class OptionDefinition < HammerCLI::Options::OptionDefinition

    attr_accessor :referenced_resource

    def initialize(switches, type, description, options = {})
      @referenced_resource = options[:referenced_resource].to_s if options[:referenced_resource]
      super
      # Apipie currently sends descriptions as escaped HTML once this is changed this should be removed.
      # See #15198 on Redmine.
      @description = CGI::unescapeHTML(description)
    end

  end

end
