require File.join(File.dirname(__FILE__), 'options')
require File.join(File.dirname(__FILE__), 'resource')

module HammerCLI::Apipie

  class Command < HammerCLI::AbstractCommand

    include HammerCLI::Apipie::Resource
    include HammerCLI::Apipie::Options

    def initialize(*args)
      setup_identifier_options
      super(*args)
    end

    def setup_identifier_options
      self.class.option "--id", "ID", "resource id" if self.class.identifier? :id
      self.class.option "--name", "NAME", "resource name" if self.class.identifier? :name
      self.class.option "--label", "LABEL", "resource label" if self.class.identifier? :label
    end

    def self.identifiers *keys
      @identifiers = keys
    end

    def validate_options
      super
      validator.any(*self.class.declared_identifiers).required
    end

    protected

    def get_identifier
      self.class.declared_identifiers.each do |identifier|
        value = send(identifier)
        return [value, identifier] if value
      end
      [nil, nil]
    end

    def self.identifier? key
      if @identifiers
        return true if @identifiers.include? key
      else
        return true if superclass.respond_to?(:identifier?, true) and superclass.identifier?(key)
      end
      return false
    end

    def self.declared_identifiers
      if @identifiers
        return @identifiers
      elsif superclass.respond_to?(:declared_identifiers, true)
        superclass.declared_identifiers
      else
        []
      end
    end

  end
end
