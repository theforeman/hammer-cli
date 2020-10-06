
module HammerCLI::Apipie
  module Options

    def method_options(options)
      method_options_for_params(resource.action(action).params, options)
    end

    def method_options_for_params(params, options)
      opts = {}

      params.each do |p|
        if p.expected_type == :hash && !p.params.empty?
          opts[p.name] = method_options_for_params(p.params, options)
        else
          p_name = HammerCLI.option_accessor_name(p.name)
          if options.key?(p_name)
            opts[p.name] = options[p_name]
          elsif respond_to?(p_name, true)
            opt = send(p_name)
            opts[p.name] = opt unless opt.nil?
          end
        end
      end

      opts
    end

    def get_option_value(opt_name)
      if respond_to?(HammerCLI.option_accessor_name(opt_name), true)
        send(HammerCLI.option_accessor_name(opt_name))
      else
        nil
      end
    end

  end
end
