
module HammerCLI::Apipie

  class OptionBuilder < HammerCLI::AbstractOptionBuilder

    def initialize(resource, action, options={})
      @action = action
      @resource = resource
      @require_options = options[:require_options].nil? ? true : options[:require_options]
    end

    def build(builder_params={})
      filter = Array(builder_params[:without])
      resource_name_map = builder_params[:resource_mapping] || {}

      options_for_params(@action.params, filter, resource_name_map)
    end

    attr_writer :require_options
    def require_options?
      @require_options
    end

    protected

    def option(*args)
      HammerCLI::Apipie::OptionDefinition.new(*args)
    end

    def options_for_params(params, filter, resource_name_map)
      opts = []
      params.each do |p|
        next if filter.include?(p.name) || filter.include?(p.name.to_sym)
        if p.expected_type == :hash
          opts += options_for_params(p.params, filter, resource_name_map)
        else
          opts << create_option(p, resource_name_map)
        end
      end
      opts
    end

    def create_option(param, resource_name_map)
      family = HammerCLI::Options::OptionFamily.new
      family.parent(option_switch(param, resource_name_map),
                    option_type(param, resource_name_map),
                    option_desc(param),
                    option_opts(param, resource_name_map))
    end

    def option_switch(param, resource_name_map)
      '--' + optionamize(aliased(param, resource_name_map))
    end

    def option_type(param, resource_name_map)
      aliased(param, resource_name_map).upcase.gsub('-', '_')
    end

    def option_desc(param)
      param.description || " "
    end

    def option_opts(param, resource_name_map)
      opts = {}
      opts[:required] = true if (param.required? and require_options?)
      if param.expected_type.to_s == 'array'
        if param.params.empty?
          opts[:format] = HammerCLI::Options::Normalizers::List.new
        else
          opts[:format] = HammerCLI::Options::Normalizers::ListNested.new(param.params)
        end
      elsif param.expected_type.to_s == 'boolean' || param.validator.to_s == 'boolean'
        opts[:format] = HammerCLI::Options::Normalizers::Bool.new
      elsif param.expected_type.to_s == 'string' && param.validator =~ /Must be one of: (.*)\./
        allowed = $1.split(/,\ ?/).map { |val| val.gsub(/<[^>]*>/i,'') }
        opts[:format] = HammerCLI::Options::Normalizers::Enum.new(allowed)
      elsif param.expected_type.to_s == 'numeric'
        opts[:format] = HammerCLI::Options::Normalizers::Number.new
      end
      opts[:attribute_name] = HammerCLI.option_accessor_name(param.name)
      opts[:referenced_resource] = resource_name(param)
      opts[:aliased_resource] = aliased_name(resource_name(param), resource_name_map)

      return opts
    end

    def aliased_name(name, resource_name_map)
      return if name.nil?

      resource_name_map[name.to_s] || resource_name_map[name.to_sym] || name
    end

    def aliased(param, resource_name_map)
      resource_name = resource_name(param)
      return param.name if resource_name.nil?

      param.name.gsub(resource_name, aliased_name(resource_name, resource_name_map).to_s)
    end

    def resource_name(param)
      if (param.name =~ /^id[s]?$/)
        @resource.singular_name
      elsif(param.name =~ /_id[s]?$/)
        param.name.to_s.gsub(/_id[s]?$/, "")
      else
        nil
      end
    end

  end
end
