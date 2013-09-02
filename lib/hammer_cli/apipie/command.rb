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
      self.class.identifier_option(:id, "resource id")
      self.class.identifier_option(:name, "resource name")
      self.class.identifier_option(:label, "resource label")
    end

    def self.identifiers *keys
      @identifiers ||= {}
      keys.each do |key|
        if key.is_a? Hash
          @identifiers.merge!(key)
        else
          @identifiers.update(key => key)
        end
      end
    end

    def validate_options
      super
      validator.any(*self.class.declared_identifiers.values).required
    end

    def self.desc(desc=nil)
      super(desc) || method_doc["apis"][0]["short_description"]
    rescue
      " "
    end

    protected

    def get_identifier
      self.class.declared_identifiers.keys.each do |identifier|
        value = find_option("--"+identifier.to_s).of(self).read
        return [value, identifier] if value
      end
      [nil, nil]
    end

    def self.identifier? key
      if @identifiers
        return true if @identifiers.keys.include? key
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
        {}
      end
    end

    private

    def self.identifier_option(name, desc)
      attr_name = declared_identifiers[name]
      option "--"+name.to_s, name.to_s.upcase, desc, :attribute_name => attr_name if self.identifier? name
    end

  end
end
