
module HammerCLI::Apipie

  class OptionBuilder

    def initialize(action, options={})
      @action = action
      @require_options = options[:require_options].nil? ? true : options[:require_options]
    end

    def build(builder_params={})
      filter = Array(builder_params[:without])

      options_for_params(@action.params, filter)
    end

    attr_writer :require_options
    def require_options?
      @require_options
    end

    protected

    def options_for_params(params, filter)
      opts = []
      params.each do |p|
        next if filter.include?(p.name) || filter.include?(p.name.to_sym)
        if p.expected_type == :hash
          opts += options_for_params(p.params, filter)
        else
          opts << create_option(p)
        end
      end
      opts
    end

    def create_option(param)
      HammerCLI::Options::OptionDefinition.new(
        option_switch(param),
        option_type(param),
        option_desc(param),
        option_opts(param)
      )
    end

    def option_switch(param)
      '--' + param.name.gsub('_', '-')
    end

    def option_type(param)
      param.name.upcase.gsub('-', '_')
    end

    def option_desc(param)
      param.description || " "
    end

    def option_opts(param)
      opts = {}
      opts[:required] = true if (param.required? and require_options?)
      # FIXME: There is a bug in apipie, it does not produce correct expected type for Arrays
      # When it's fixed, we should test param["expected_type"] == "array"
      opts[:format] = HammerCLI::Options::Normalizers::List.new if param.validator.include? "Array"
      return opts
    end


  end
end
