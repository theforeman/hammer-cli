require File.join(File.dirname(__FILE__), '../abstract')
require File.join(File.dirname(__FILE__), 'options')
require File.join(File.dirname(__FILE__), 'resource')

module HammerCLI::Apipie

  class Command < HammerCLI::AbstractCommand

    include HammerCLI::Apipie::Resource
    include HammerCLI::Apipie::Options

    def self.identifiers(*keys)
      @identifiers ||= {}
      keys.each do |key|
        if key.is_a? Hash
          @identifiers.merge!(key)
        else
          @identifiers.update(key => HammerCLI.option_accessor_name(key))
        end
      end
    end

    def validate_options
      super
      if self.class.declared_identifiers
        validator.any(*self.class.declared_identifiers.values).required
      end
    end

    def self.desc(desc=nil)
      super(desc) || resource.docs_for(action)["apis"][0]["short_description"]
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

    def self.identifier?(key)
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

    def self.setup_identifier_options
      identifier_option(:id, _("resource id"), declared_identifiers[:id]) if identifier? :id
      identifier_option(:name, _("resource name"), declared_identifiers[:name]) if identifier? :name
      identifier_option(:label, _("resource label"), declared_identifiers[:label]) if identifier? :label
    end

    def self.identifier_option(name, desc, attr_name)
      option_switch = '--'+name.to_s.gsub('_', '-')

      if name == :id
        option option_switch, name.to_s.upcase, desc, :attribute_name => attr_name
      else
        option option_switch, name.to_s.upcase, desc, :attribute_name => attr_name do |value|
          name_to_id(value, name, resource)
        end
      end
    end

    def name_to_id(name, option_name, resource)
      results = resource.call(:index, :search => "#{option_name} = #{name}")
      results = HammerCLIForeman.collection_to_common_format(results)

      msg_opts = {
        :resource => resource.name,
        :option => option_name,
        :value => name
      }
      raise _("%{resource} with %{option} '%{value}' not found") % msg_opts if results.empty?
      raise _("%{resource} with %{option} '%{value}' found more than once") % msg_opts if results.count > 1
      results[0]['id']
    end

  end
end
