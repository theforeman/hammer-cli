
module HammerCLI::Apipie

  class OptionBuilder < HammerCLI::AbstractOptionBuilder

    def initialize(action, options={})
      @action = action
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
      option(
        option_switch(param, resource_name_map),
        option_type(param, resource_name_map),
        option_desc(param),
        option_opts(param)
      )
    end

    def option_switch(param, resource_name_map)
      '--' + optionamize(aliased(param.name, resource_name_map))
    end

    def option_type(param, resource_name_map)
      aliased(param.name, resource_name_map).upcase.gsub('-', '_')
    end

    def option_desc(param)
      param.description || " "
    end

    def option_opts(param)
      opts = {}
      opts[:required] = true if (param.required? and require_options?)
      if param.expected_type == :array || param.validator =~ /Array/i
        opts[:format] = HammerCLI::Options::Normalizers::List.new
      end
      opts[:attribute_name] = HammerCLI.option_accessor_name(param.name)
      return opts
    end

    def aliased(name, resource_name_map)
      resource_name = name.gsub(/_id[s]?$/, "")
      resource_name = resource_name_map[resource_name.to_s] || resource_name_map[resource_name.to_sym] || resource_name
      if name.end_with?("_id")
        return "#{resource_name}_id"
      elsif name.end_with?("_ids")
        return "#{resource_name}_ids"
      else
        return name
      end
    end

  end
end
