require File.join(File.dirname(__FILE__), '../abstract')
require File.join(File.dirname(__FILE__), 'options')
require File.join(File.dirname(__FILE__), 'resource')

module HammerCLI::Apipie

  class Command < HammerCLI::AbstractCommand

    include HammerCLI::Apipie::Resource
    include HammerCLI::Apipie::Options

    def self.desc(desc=nil)
      super(desc) || resource.action(action).apidoc[:apis][0][:short_description] || " "
    rescue
      " "
    end

    def self.custom_option_builders
      builders = super
      builders += [
        OptionBuilder.new(resource.action(action), :require_options => false)
      ] if resource_defined?
      builders
    end

    def self.apipie_options(*args)
      self.build_options(*args)
    end

  end
end
